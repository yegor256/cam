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

HOME=dataset
TOTAL=4

all: env $(HOME)/repositories.csv cleanup clone filter measure aggregate zip

# Zip the entire dataset into an archive.
zip: $(HOME)/report.pdf
	rm -r $(HOME)/temp
	zip -r "cam-$$(date +%Y-%m-%d).zip" "$(HOME)"

# Delete calculations.
clean:
	rm -rf "$(HOME)/measurements"
	rm -rf "$(HOME)/data"
	rm -rf "$(HOME)/reports"
	rm -rf "$(HOME)/temp"

# Delete everything, in order to start from scratch.
wipe:
	rm -rf "$(HOME)"

# Show some details about the environment we are running it
# (this is mostly for debugging in Docker)
env:
	ruby -v
	python --version

# Get the list of repos from GitHub and then create directories
# for them. Each dir will be empty.
$(HOME)/repositories.csv:
	ruby discover-repos.rb --total=$(TOTAL) "--path=$(HOME)/repositories.csv"
	cat "$(HOME)/repositories.csv"

# Delete directories that don't exist in the list of
# required repositories.
cleanup: $(HOME)/repositories.csv $(HOME)/github
	for d in $$(find "$(HOME)/github" -maxdepth 2 -mindepth 2 -type d -print); do
		repo=$$(echo $${d} | sed "s|$(HOME)/github/||")
		if grep -Fxq "$${repo}" $(HOME)/repositories.csv; then
			echo "Directory $${d} is here and is needed (for $${repo})"
		else
			rm -rf "$${d}"
			echo "Directory $${d} is obsolete and was deleted (for $${repo})"
		fi
	done
	for d in $$(find "$(HOME)/github" -maxdepth 1 -mindepth 1 -type d -print); do
		if [ "$$(ls $${d} | wc -l)" == '0' ]; then
			rm -rf "$${d}"
			echo "Directory $${d} is empty and was deleted"
		fi
	done

# Clone all necessary repositories.
# Don't touch those that already have any files in the dirs.
clone: $(HOME)/repositories.csv $(HOME)/github
	while IFS= read -r r; do
	  	if [ -e "$(HOME)/github/$${r}/.git" ]; then
	    	echo "$${r}: Git repo is already here"
	  	else
	    	echo "$${r}: trying to clone it..."
	    	git clone "https://github.com/$${r}" "$(HOME)/github/$${r}"
	  	fi
	done < "$(HOME)/repositories.csv"

# Apply filters to all found repositories at once.
filter: $(HOME)/github $(HOME)/temp
	mkdir -p $(HOME)/temp/reports
	for f in $$(ls filters/); do
		"filters/$${f}" $(HOME)/github "$(HOME)/temp/reports/$${f}.tex" $(HOME)/temp
		echo "Filter $${f} published its results to $(HOME)/temp/reports/$${f}.tex"
	done
	for f in $$(ls "$(HOME)/reports/"); do
		echo "$${f}:"
		cat "$(HOME)/reports/$${f}"
		echo ""
	done

# Calculate metrics for each file.
measure: $(HOME)/github $(HOME)/temp $(HOME)/measurements
	for f in $$(find $(HOME)/github -name '*.java'); do
		java="$${f}"
		javam="$$(echo "$${java}" | sed "s|$(HOME)/github|$(HOME)/measurements|").m"
		if [ -e "$${javam}" ]; then
			echo "Metrics already exist for $${java}"
			continue
		fi
		mkdir -p $$(dirname "$${javam}")
		for m in $$(ls metrics/); do
			"metrics/$${m}" "$${java}" "$${javam}"
			while IFS= read -r t; do
				IFS=' ' read -ra M <<< "$${t}"
				echo "$${M[1]}" > "$${javam}.$${M[0]}"
			done < "$${javam}"
		done
		echo "Metrics collected for $${java}"
	done

# Aggregate all metrics in summary CSV files.
aggregate: $(HOME)/measurements $(HOME)/data
	all=$$(find $(HOME)/measurements -name '*.m.*' -print | sed "s|^.*\.\(.*\)$$|\1|" | sort | uniq | tr '\n' ' ')
	echo "All metrics: $${all}"
	for d in $$(find $(HOME)/measurements -maxdepth 2 -mindepth 2 -type d -print); do
		ddir=$$(echo "$${d}" | sed "s|$(HOME)/measurements|$(HOME)/data|")
		if [ -e "$${ddir}" ]; then
			echo "Already aggregated: $${ddir}"
			continue
		fi
		for m in $$(find "$${d}" -name '*.m' -print); do
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
	rm -rf $(HOME)/data/*.csv
	printf "repository,file" >> $(HOME)/data/all.csv
	for a in $${all}; do
		printf ",$${a}" >> $(HOME)/data/all.csv
	done
	printf "\n" >> $(HOME)/data/all.csv
	for d in $$(find $(HOME)/data -maxdepth 2 -mindepth 2 -type d -print); do
		r=$$(echo "$${d}" | sed "s|$(HOME)/data/||")
		for csv in $$(find "$${d}" -name '*.csv' -maxdepth 1 -print); do
			a=$$(echo "$${csv}" | sed "s|$${d}||")
			while IFS= read -r t; do
				echo "$${r},$${t}" >> "$(HOME)/data/$${a}"
			done < "$${csv}"
		done
		echo "$${r} metrics added to the CSV aggregate"
	done

$(HOME)/report.pdf:
	cd tex
	make clean
	make
	cd ..
	cp tex/report.pdf $(HOME)/report.pdf

$(HOME)/github:
	mkdir -p "$(HOME)/github"

$(HOME)/data:
	mkdir -p "$(HOME)/data"

$(HOME)/measurements:
	mkdir -p "$(HOME)/measurements"

$(HOME)/temp:
	mkdir -p "$(HOME)/temp"
