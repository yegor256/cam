# The MIT License (MIT)
#
# Copyright (c) 2021 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

SHELL := /bin/bash

.SHELLFLAGS = -e -o pipefail -c
.ONESHELL:

# The place where all the data will be stored and managed.
TARGET=dataset

# Total number of repositories to fetch from GitHub.
TOTAL=4

lint:
	flake8 metrics/
	pylint metrics/

all: env $(TARGET)/repositories.csv cleanup clone filter measure aggregate zip

# Zip the entire dataset into an archive.
zip: $(TARGET)/report.pdf
	rm -r $(TARGET)/temp
	zip -r "cam-$$(date +%Y-%m-%d).zip" "$(TARGET)"
	mv "cam-$$(date +%Y-%m-%d).zip" "$(TARGET)"

# Delete calculations.
clean:
	rm -rf "$(TARGET)/report.pdf"
	rm -rf "$(TARGET)/measurements"
	rm -rf "$(TARGET)/data"
	rm -rf "$(TARGET)/reports"
	rm -rf "$(TARGET)/temp"

# Delete everything, in order to start from scratch.
wipe: clean
	rm -rf "$(TARGET)"

# Show some details about the environment we are running it
# (this is mostly for debugging in Docker)
env:
	ruby -v
	python --version

# Get the list of repos from GitHub and then create directories
# for them. Each dir will be empty.
$(TARGET)/repositories.csv:
	ruby discover-repos.rb --total=$(TOTAL) "--path=$(TARGET)/repositories.csv"
	cat "$(TARGET)/repositories.csv"

# Delete directories that don't exist in the list of
# required repositories.
cleanup: $(TARGET)/repositories.csv $(TARGET)/github
	for d in $$(find "$(TARGET)/github" -maxdepth 2 -mindepth 2 -type d -print); do
		repo=$$(echo $${d} | sed "s|$(TARGET)/github/||")
		if grep -Fxq "$${repo}" $(TARGET)/repositories.csv; then
			echo "Directory $${d} is here and is needed (for $${repo})"
		else
			rm -rf "$${d}"
			echo "Directory $${d} is obsolete and was deleted (for $${repo})"
		fi
	done
	for d in $$(find "$(TARGET)/github" -maxdepth 1 -mindepth 1 -type d -print); do
		if [ "$$(ls $${d} | wc -l)" == '0' ]; then
			rm -rf "$${d}"
			echo "Directory $${d} is empty and was deleted"
		fi
	done

# Clone all necessary repositories.
# Don't touch those that already have any files in the dirs.
clone: $(TARGET)/repositories.csv $(TARGET)/github
	while IFS= read -r r; do
	  	if [ -e "$(TARGET)/github/$${r}/.git" ]; then
	    	echo "$${r}: Git repo is already here"
	  	else
	    	echo "$${r}: trying to clone it..."
	    	git clone --depth 1 "https://github.com/$${r}" "$(TARGET)/github/$${r}"
			printf "$${r},$$(git --git-dir "$(TARGET)/github/$${r}/.git" rev-parse HEAD)\n" >> "$(TARGET)/hashes.csv"
	  	fi
	done < "$(TARGET)/repositories.csv"

# Apply filters to all found repositories at once.
filter: $(TARGET)/github $(TARGET)/temp
	mkdir -p $(TARGET)/temp/reports
	for f in $$(ls filters/); do
		"filters/$${f}" $(TARGET)/github "$(TARGET)/temp/reports/$${f}.tex" $(TARGET)/temp
		echo "Filter $${f} published its results to $(TARGET)/temp/reports/$${f}.tex"
	done
	for f in $$(ls "$(TARGET)/temp/reports/"); do
		echo "$${f}:"
		cat "$(TARGET)/temp/reports/$${f}"
		echo ""
	done

# Calculate metrics for each file.
measure: $(TARGET)/github $(TARGET)/temp $(TARGET)/measurements
	echo "Searching for all .java files in $(TARGET)/github (may take some time, stay calm...)"
	find $(TARGET)/github -name '*.java' | while IFS= read -r f; do
		java="$${f}"
		javam="$$(echo "$${java}" | sed "s|$(TARGET)/github|$(TARGET)/measurements|").m"
		if [ -e "$${javam}" ]; then
			echo "Metrics already exist for $${java}"
			continue
		fi
		mkdir -p $$(dirname "$${javam}")
		for m in $$(ls metrics/); do
			if "metrics/$${m}" "$${java}" "$${javam}"; then
				while IFS= read -r t; do
					IFS=' ' read -ra M <<< "$${t}"
					echo "$${M[1]}" > "$${javam}.$${M[0]}"
				done < "$${javam}"
			else
				echo "Failed to collect $${m} for $${java}"
			fi
		done
		echo "Metrics collected for $${java}"
	done

# Aggregate all metrics in summary CSV files.
aggregate: $(TARGET)/measurements $(TARGET)/data
	all=$$(find $(TARGET)/measurements -name '*.m.*' -print | sed "s|^.*\.\(.*\)$$|\1|" | sort | uniq | tr '\n' ' ')
	echo "All metrics: $${all}"
	for d in $$(find $(TARGET)/measurements -maxdepth 2 -mindepth 2 -type d -print); do
		ddir=$$(echo "$${d}" | sed "s|$(TARGET)/measurements|$(TARGET)/data|")
		if [ -e "$${ddir}" ]; then
			echo "Already aggregated: $${ddir}"
			continue
		fi
		find "$${d}" -name '*.m' | while IFS= read -r m; do
			for v in $$(ls $${m}.*); do
				java=$$(echo "$${v}" | sed "s|$${d}||" | sed "s|\.m\..*$$||")
				metric=$$(echo "$${v}" | sed "s|$${d}$${java}.m.||")
				csv="$${ddir}/$${metric}.csv"
				mkdir -p $$(dirname "$${csv}")
				echo "$${java},$$(cat "$${v}")" >> "$${csv}"
			done
			csv="$${ddir}/all.csv"
			mkdir -p $$(dirname "$${csv}")
			java=$$(echo "$${m}" | sed "s|$${d}||" | sed "s|\.m$$||")
			printf "$${java}" >> "$${csv}"
			for a in $${all}; do
				printf ",$$(cat "$${m}.$${a}")" >> "$${csv}"
			done
			printf "\n" >> "$${csv}"
		done
		echo "$${d} aggregated"
	done
	rm -rf $(TARGET)/data/*.csv
	printf "repository,file" >> $(TARGET)/data/all.csv
	for a in $${all}; do
		printf ",$${a}" >> $(TARGET)/data/all.csv
	done
	printf "\n" >> $(TARGET)/data/all.csv
	for d in $$(find $(TARGET)/data -maxdepth 2 -mindepth 2 -type d -print); do
		r=$$(echo "$${d}" | sed "s|$(TARGET)/data/||")
		for csv in $$(find "$${d}" -name '*.csv' -maxdepth 1 -print); do
			a=$$(echo "$${csv}" | sed "s|$${d}||")
			while IFS= read -r t; do
				echo "$${r},$${t}" >> "$(TARGET)/data/$${a}"
			done < "$${csv}"
		done
		echo "$${r} metrics added to the CSV aggregate"
	done

$(TARGET)/report.pdf:
	cd tex
	make clean
	make
	cd ..
	cp tex/report.pdf $(TARGET)/report.pdf

$(TARGET)/github:
	mkdir -p "$(TARGET)/github"

$(TARGET)/data:
	mkdir -p "$(TARGET)/data"

$(TARGET)/measurements:
	mkdir -p "$(TARGET)/measurements"

$(TARGET)/temp:
	mkdir -p "$(TARGET)/temp"
