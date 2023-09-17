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
.SILENT:

SHELL := bash

# The place where all the data will be stored and managed.
TARGET = dataset

# Total number of repositories to fetch from GitHub.
TOTAL = 1

# GitHub auth token
TOKEN =

# Path to file with repositories names joined by newlines
REPOS =

# Single repository name to use (mostly for testing purposes)
REPO =

# Where all files are kept
HOME := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Location of jpeek JAR file
JPEEK = /opt/app/jpeek-0.32.0-jar-with-dependencies.jar

# Make all variables from this Makefile visible in all steps/*.sh
export

# The main goal
all: env lint $(TARGET)/start.txt $(TARGET)/repositories.csv cleanup clone jpeek filter measure aggregate zip

install:
	./steps/install.sh

# Record the moment in time, when processing started.
$(TARGET)/start.txt: $(TARGET)/temp
	ruby -e "print Time.now.to_i" > $(TARGET)/start.txt

# Check the quality of code
lint:
	./steps/lint.sh

# Zip the entire dataset into an archive.
zip: $(TARGET)/report.pdf
	set -e
	zip -qq -r "cam-$$(date +%Y-%m-%d).zip" "$(TARGET)"
	mv "cam-$$(date +%Y-%m-%d).zip" "$(TARGET)"

# Delete calculations.
clean:
	set -e
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
	    "$(SHELL)" -version
	    echo "$(SHELL) version is older than five: ${BASH_VERSINFO:-0}"
	    exit -1
	fi
	ruby -v
	python3 --version
	if [[ "$$(python3 --version 2>&1 | cut -f2 -d' ')" =~ ^[1-2] ]]; then
	    echo "Python must be 3+"
	    exit -1
	fi
	flake8 --version
	pylint --version
	xmlstarlet --version
	shellcheck --version
	pdflatex --version
	aspell --version
	cloc --version
	pmd pmd --version
	java -jar "$(JPEEK)" --help

# Get the list of repos from GitHub and then create directories
# for them. Each dir will be empty.
$(TARGET)/repositories.csv: $(TARGET)/temp
	./steps/discover.sh

# Delete directories that don't exist in the list of
# required repositories.
cleanup: $(TARGET)/repositories.csv $(TARGET)/github
	./steps/clean.sh

# Clone all necessary repositories.
# Don't touch those that already have any files in the dirs.
clone: $(TARGET)/repositories.csv $(TARGET)/github
	./steps/clone.sh

# Try to build classes and run jpeek for the entire repo.
jpeek: $(TARGET)/repositories.csv $(TARGET)/github
	./steps/jpeek.sh

# Apply filters to all found repositories at once.
filter: $(TARGET)/github $(TARGET)/temp
	./steps/filter.sh

# Calculate metrics for each file.
measure: $(TARGET)/github $(TARGET)/temp $(TARGET)/measurements
	./steps/measure.sh

# Aggregate all metrics in summary CSV files.
aggregate: $(TARGET)/measurements $(TARGET)/data
	./steps/aggregate.sh

$(TARGET)/report.pdf: $(TARGET)/temp paper/paper.tex
	./steps/report.sh

$(TARGET)/github:
	mkdir -p "$(TARGET)/github"

$(TARGET)/data:
	mkdir -p "$(TARGET)/data"

$(TARGET)/measurements:
	mkdir -p "$(TARGET)/measurements"

$(TARGET)/temp:
	mkdir -p "$(TARGET)/temp"
