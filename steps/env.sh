#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail
set -x

echo "TARGET=${TARGET}"
echo "LOCAL=${LOCAL}"
echo "SHELL=${SHELL}"
echo "HOME=${HOME}"

env

bash_version=${BASH_VERSINFO:-0}
if [ "${bash_version}" -lt 5 ]; then
    "${SHELL}" --version
    ps -p $$
    echo "${SHELL} version must be 5 or higher. Current ${SHELL} version: ${bash_version}"
    exit 1
fi

ruby -v
rubocop -v

if [[ "$(python3 --version 2>&1 | cut -f2 -d' ')" =~ ^[1-2] ]]; then
    python3 --version
    echo "Python must be 3+"
    exit 1
fi
flake8 --version
pylint --version

if ! tlmgr --version >/dev/null 2>&1; then
  PATH=$PATH:$("${LOCAL}/help/texlive-bin.sh")
  export PATH
fi
pdflatex --version
pdftotext -v
inkscape --version
aspell --version
latexmk --version

xmlstarlet --version

shellcheck --version

jq --version

multimetric --help > /dev/null

awk --version

parallel --version

git --version

cloc --version

pmd --version

nproc --version

# Part of coreutils (by GNU):
sed --version

# Part of coreutils (by GNU):
realpath --version

bc -v

javac -version
java -jar "${JPEEK}" --help
gradle --version
mvn --version

locale
