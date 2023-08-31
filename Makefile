# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
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

.SHELLFLAGS: -e -o pipefail -c
.ONESHELL:
.PHONY: clone filter measure cleanup env lint zip wipe clean

SHELL := bash

PYTHON = python3
RUBY = ruby
JPEEK_JAR = /opt/app/jpeek-0.30.25-jar-with-dependencies.jar
JPEEK = java -jar "$(JPEEK_JAR)" --overwrite --include-ctors --include-static-methods --include-private-methods
JPEEKCVC = java -jar "$(JPEEK_JAR)" --overwrite

# The place where all the data will be stored and managed.
TARGET = dataset

# Total number of repositories to fetch from GitHub.
TOTAL = 1

# GitHub auth token
TOKEN =

# Path to repositories names joined by newlines to take from
REPOS =

all: env lint $(TARGET)/start.txt $(TARGET)/repositories.csv cleanup clone jpeek filter measure aggregate zip

# Record the moment in time, when processing started.
$(TARGET)/start.txt: $(TARGET)/temp
	$(RUBY) -e "print Time.now.to_i" > $(TARGET)/start.txt

# Check the quality of code
lint:
	flake8 metrics/
	pylint metrics/
	shellcheck -P metrics/*.sh -P filters/*.sh

# Zip the entire dataset into an archive.
zip: $(TARGET)/report.pdf
	zip -qq -r "cam-$$(date +%Y-%m-%d).zip" "$(TARGET)"
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
	if [ "$${BASH_VERSINFO:-0}" -lt 5 ]; then
		$(SHELL) -version
	  	echo "$(SHELL) version is older than five: $${BASH_VERSINFO:-0}"
	  	exit -1
	fi
	set -x
	$(RUBY) -v
	$(PYTHON) --version
	if [[ "$$($(PYTHON) --version 2>&1 | cut -f2 -d' ')" =~ ^[1-2] ]]; then
	  	echo "Python must be 3+"
	  	exit -1
	fi
	flake8 --version
	pylint --version
	java -jar "$(JPEEK_JAR)" --help

# Get the list of repos from GitHub and then create directories
# for them. Each dir will be empty.
$(TARGET)/repositories.csv: $(TARGET)/temp
	csv="$(TARGET)/repositories.csv"
	if [ test -z "$(REPOS)" ] || [ ! -e "$(REPOS)" ];
	then
		echo "Using discover-repos.rb..."
		$(RUBY) discover-repos.rb --token=$(TOKEN) --total=$(TOTAL) "--path=$${csv}" "--tex=$(TARGET)/temp/repo-details.tex"
	else
		echo "Using repos list of csv..."
		cat "$(REPOS)" >> "$${csv}"
	fi
	cat "$${csv}"

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
	while IFS=',' read -r r tag; do
	  	if [ -e "$(TARGET)/github/$${r}/.git" ]; then
	    	echo "$${r}: Git repo is already here"
			git reset --hard
	  	else
	    	echo "$${r}: trying to clone it..."
			if [ -z "$${tag}" ]; then
				git clone --depth 1 "https://github.com/$${r}" "$(TARGET)/github/$${r}"
			else
				git clone --depth 1 --branch="$${tag}" "https://github.com/$${r}" "$(TARGET)/github/$${r}"
			fi
			printf "$${r},$$(git --git-dir "$(TARGET)/github/$${r}/.git" rev-parse HEAD)\n" >> "$(TARGET)/hashes.csv"
	  	fi
	done < "$(TARGET)/repositories.csv"

# Try to build classes and run jpeek for the entire repo.
jpeek: $(TARGET)/repositories.csv $(TARGET)/github
	echo "Jpeek'ing..."
	for project in $$(find "$(TARGET)/github" -depth -maxdepth 4 -mindepth 2 -type d -print); do
		echo "Building project: $${project}"
		if [ -e "$${project}/gradlew" ]; then
			echo "Using gradlew"
			$${project}/gradlew classes -p "$${project}"
		elif [ -e "$${project}/build.gradle" ]; then
			echo "Using build.gradle"
			echo "apply plugin: 'java'" >> "$${d}/build.gradle"
			gradle classes -p "$${project}"
		elif [ -e "$${project}/pom.xml" ]; then
			echo "Using mvn install"
			mvn compiler:compile -Dmaven.test.skip=true -f "$${project}" -U
		else
			echo "Could not build classes (not maven nor gradle project)..."
			continue
		fi
		measurements="$$(echo "$${project}" | sed "s|$(TARGET)/github|$(TARGET)/jpeek|")"
		dir="$(TARGET)/temp/jpeek"
		echo "Old-fashioned..."
		$(JPEEK) --sources "$${project}" --target "$${dir}"
		echo "Ctors vs cohesion..."
		$(JPEEKCVC) --sources "$${project}" --target "$${dir}cvc"
		accept=".*[^index|matrix|skeleton].xml"
		lastm=""
		for jpeek in "$${dir}" "$${dir}cvc"; do
			echo "$${jpeek}"
			for report in $$(find "$${jpeek}" -type f -maxdepth 1); do
				metric="$$(basename "$${report}" | sed "s|.xml||")"
				suffix=$$(echo "$${jpeek}" | sed "s|$${dir}||")
				descsuffix=""
				if [ "$${suffix}" != "" ];
				then
					suffix="($${suffix})"
					descsuffix="In this case, the constructors are excluded from the metric formulas."
				fi
				if echo $${report} | grep -q $${accept} ; then
					echo "found $${report}";
					packages="$$(xmlstarlet sel -t -v 'count(/metric/app/package/@id)' "$${report}")"
					name="$$(xmlstarlet sel -t -v "/metric/title" "$${report}")"
					description="$$(xmlstarlet sel -t -v "/metric/description" "$${report}" | tr "\n" " " | sed "s|\s+| |g") $${descsuffix}"
					for ((i=1; i <= $${packages}; i++))
					do
						package="$$(echo "$$(xmlstarlet sel -t -v "/metric/app/package[$${i}]/@id" "$${report}")" | sed "s|\.|/|g")"
						classes="$$(xmlstarlet sel -t -v "count(/metric/app/package[$${i}]/class/@id)" "$${report}")"
						for ((j=0; j <= $${classes}; j++))
						do
							class="$$(xmlstarlet sel -t -v "/metric/app/package[$${i}]/class[$${j}]/@id" "$${report}")"
							value="$$(xmlstarlet sel -t -v "/metric/app/package[$${i}]/class[$${j}]/@value" "$${report}")"
							mfile="$$(find "$${project}" -path "*$${package}/$${class}.java" | sed "s|/github|/jpeek|")"
							if [ "$${mfile}" != "" ]
							then
						  		echo "$${package}/$${class}: $${value}"
								mkdir -p "$$(dirname $${mfile})"
								echo "$${name}$${suffix} $${value} $${name}" >> "$${mfile}"
								lastm="$${mfile}"
							else
								echo "$${package}/$${class}: can't find corresponding file"
							fi
						done
					done
				fi
			done
		done

	done

# Apply filters to all found repositories at once.
filter: $(TARGET)/github $(TARGET)/temp
	mkdir -p "$(TARGET)/temp/reports"
	for f in $$(ls filters/); do
		echo "Running filter $${f}... (may take some time)"
		"filters/$${f}" "$(TARGET)/github" "$(TARGET)/temp" |\
			tr -d '\n\r' |\
			sed "s/^/\\\\item /" |\
			sed "s/$$/;/" \
			> "$(TARGET)/temp/reports/$${f}.tex"
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
	find "$(TARGET)/github" -name '*.java' | while IFS= read -r f; do
		java="$${f}"
		javam="$$(echo "$${java}" | sed "s|$(TARGET)/github|$(TARGET)/measurements|").m"
		if [ -e "$${javam}" ]; then
			echo "Metrics already exist for $${java}"
			continue
		fi
		mkdir -p "$$(dirname "$${javam}")"
		declare -i cnt=0
		for m in $$(ls metrics/); do
			if "metrics/$${m}" "$${java}" "$${javam}"; then
				while IFS= read -r t; do
					IFS=' ' read -ra M <<< "$${t}"
					echo "$${M[1]}" > "$${javam}.$${M[0]}"
				done < "$${javam}"
				cnt=cnt+1
			else
				echo "Failed to collect $${m} for $${java}"
			fi
		done
		echo "$${cnt} metric scripts ran for $${java}"
	done

# Aggregate all metrics in summary CSV files.
aggregate: $(TARGET)/measurements $(TARGET)/data
	all=$$(find "$(TARGET)/measurements" -name '*.m.*' -print | sed "s|^.*\.\(.*\)$$|\1|" | sort | uniq | tr '\n' ' ')
	echo "All metrics: $${all}"
	for d in $$(find "$(TARGET)/measurements" -maxdepth 2 -mindepth 2 -type d -print); do
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
			mkdir -p "$$(dirname "$${csv}")"
			java=$$(echo "$${m}" | sed "s|$${d}||" | sed "s|\.m$$||")
			printf "$${java}" >> "$${csv}"
			for a in $${all}; do
				if [ -e "$${m}.$${a}" ]; then
					printf ",$$(cat "$${m}.$${a}")" >> "$${csv}"
				else
					printf ',-' >> "$${csv}"
				fi
			done
			printf "\n" >> "$${csv}"
		done
		echo "$${d} aggregated"
	done
	rm -rf "$(TARGET)/data/*.csv"
	printf "repository,file" >> "$(TARGET)/data/all.csv"
	for a in $${all}; do
		printf ",$${a}" >> "$(TARGET)/data/all.csv"
	done
	printf "\n" >> "$(TARGET)/data/all.csv"
	for d in $$(find "$(TARGET)/data" -maxdepth 2 -mindepth 2 -type d -print); do
		r=$$(echo "$${d}" | sed "s|$(TARGET)/data/||")
		for csv in $$(find "$${d}" -name '*.csv' -maxdepth 1 -print); do
			a=$$(echo "$${csv}" | sed "s|$${d}||")
			while IFS= read -r t; do
				echo "$${r},$${t}" >> "$(TARGET)/data/$${a}"
			done < "$${csv}"
		done
		echo "$${r} metrics added to the CSV aggregate"
	done

$(TARGET)/report.pdf: $(TARGET)/temp
	rm -f "$(TARGET)/temp/list-of-metrics.tex"
	for m in $$(ls metrics/); do
		echo "class Foo {}" > "$(TARGET)/temp/foo.java"
		rm -f "$(TARGET)/temp/foo.$${m}.m"
		"metrics/$${m}" "$(TARGET)/temp/foo.java" "$(TARGET)/temp/foo.$${m}.m"
		awk '{ s= "\\item\\ff{" $$1 "}: "; for (i = 3; i <= NF; i++) s = s $$i " "; print s; }' < "$(TARGET)/temp/foo.$${m}.m" >> "$(TARGET)/temp/list-of-metrics.tex"
		echo "$$(cat $(TARGET)/temp/foo.$${m}.m | wc -l) metrics from $${m}"
	done
	t=$$(realpath $(TARGET))
	cd tex
	TARGET="$${t}" latexmk -pdf
	cd ..
	cp tex/report.pdf "$(TARGET)/report.pdf"

$(TARGET)/github:
	mkdir -p "$(TARGET)/github"

$(TARGET)/data:
	mkdir -p "$(TARGET)/data"

$(TARGET)/measurements:
	mkdir -p "$(TARGET)/measurements"

$(TARGET)/temp:
	mkdir -p "$(TARGET)/temp"
