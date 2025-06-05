# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

.PHONY: clone filter measure cleanup env lint zip clean jpeek aggregate all test metrics
.SILENT:
.SHELLFLAGS := -e -o pipefail -c
.ONESHELL:

# Our version.
VERSION = 0.0.0

# The shell to use.
SHELL := bash

# The directory where all the data will be stored and managed.
TARGET = dataset

# Total number of repositories to fetch from GitHub.
TOTAL = 1

# GitHub auth token (no token is OK too).
TOKEN =

# Path to file with repositories names joined by newlines.
REPOS =

# Single repository name to use (mostly for testing purposes).
REPO =

# Where all files are kept
LOCAL := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Location of jpeek JAR file
JPEEK = /opt/app/jpeek.jar

# Options for all Java processes
JAVA_OPTS=-Xmx128m

# defines rules and symbols for formatting numeric information
LC_NUMERIC=C

# Make all variables from this Makefile visible in all steps/*.sh
export

# Run a single step from ./steps
define step
	set -e
	${LOCAL}/help/check-make.sh
	start=$$(date +%s%N)
	echo -e "\n\n\n+++ $(1) +++\n"
	source "$(LOCAL)/help/gnu-utils.sh"
	if [ -d "$(LOCAL)/venv" ]; then
		source "$(LOCAL)/venv/bin/activate"
	fi
	@bash $(LOCAL)/steps/$(1).sh
	echo "Finished$$("$${LOCAL}/help/tdiff.sh" "$${start}")"
endef

# The main goal
all: env $(TARGET)/start.txt $(TARGET)/repositories.csv polish clone unregister jpeek filter measure aggregate summarize zip
	echo -e "\n\nSUCCESS (made by yegor256/cam $(VERSION)$$("$${LOCAL}/help/tdiff.sh" "$$(cat "$(TARGET)/start.txt")"))!"

install:
	$(call step,install)

test:
	$(call step,tests)

# Record the moment in time, when processing started.
$(TARGET)/start.txt: $(TARGET)/temp
	date +%s%N > "$(TARGET)/start.txt"
	echo -e "STARTED yegor256/cam $(VERSION) at $$(date)\n\n"
	lscpu 2>/dev/null || true

# Check the quality of code
lint:
	$(call step,lint)

# Zip the entire dataset into an archive.
zip: $(TARGET)/report.pdf
	$(call step,zip)

# Delete calculations.
clean:
	rm -rf "$(TARGET)"

# Show some details about the environment we are running it
# (this is mostly for debugging in Docker)
env:
	$(call step,env)

# Get the list of repos from GitHub and then create directories
# for them. Each dir will be empty.
$(TARGET)/repositories.csv: $(TARGET)/temp
	$(call step,discover)

# Delete directories that don't exist in the list of
# required repositories.
polish: $(TARGET)/repositories.csv $(TARGET)/github
	$(call step,polish)

# Delete directories from the CSV register if their clones are absent.
unregister: $(TARGET)/repositories.csv $(TARGET)/github
	$(call step,unregister)

# Clone all necessary repositories.
# Don't touch those that already have any files in the dirs.
clone: $(TARGET)/repositories.csv $(TARGET)/github
	$(call step,clone)

# Try to build classes and run jpeek for the entire repo.
jpeek: $(TARGET)/repositories.csv $(TARGET)/github
	$(call step,jpeek)

# Apply filters to all found repositories at once.
filter: $(TARGET)/github $(TARGET)/temp
	$(call step,filter)

# Calculate metrics for each file.
measure: $(TARGET)/github $(TARGET)/temp $(TARGET)/measurements
	$(call step,measure)

# Aggregate all metrics in summary CSV files.
aggregate: $(TARGET)/measurements $(TARGET)/data
	$(call step,aggregate)

# Summarize aggregated metrics in summary CSV files.
summarize: $(TARGET)/measurements $(TARGET)/data
	$(call step,summarize)

# Collect and print all available metrics with their count.
metrics: $(TARGET)/temp
	$(call step,metrics)

$(TARGET)/report.pdf: $(TARGET)/temp tex/report.tex
	$(call step,report)

$(TARGET)/github:
	mkdir -p "$(TARGET)/github"

$(TARGET)/data:
	mkdir -p "$(TARGET)/data"

$(TARGET)/measurements:
	mkdir -p "$(TARGET)/measurements"

$(TARGET)/temp:
	mkdir -p "$(TARGET)/temp"
