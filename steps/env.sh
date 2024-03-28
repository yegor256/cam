#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2024 Yegor Bugayenko
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
    "${SHELL}" -version
    ps -p $$
    echo "${SHELL} version is older than five: ${bash_version}"
    exit 1
fi

ruby -v

if [[ "$(python3 --version 2>&1 | cut -f2 -d' ')" =~ ^[1-2] ]]; then
    python3 --version
    echo "Python must be 3+"
    exit 1
fi


if ! tlmgr --version >/dev/null 2>&1; then
  PATH=$PATH:$("${LOCAL}/help/texlive-bin.sh")
  export PATH
fi

flake8 --version

pylint --version

xmlstarlet --version

shellcheck --version

pdflatex --version

aspell --version

jq --version

multimetric --help > /dev/null

rubocop -v

inkscape --version

awk --version

parallel --version

git --version

cloc --version

pmd pmd --version

gradle --version

mvn --version

pdftotext -v

nproc --version

# Part of coreutils (by GNU):
sed --version

# Part of coreutils (by GNU):
realpath --version

bc -v

javac -version

java -jar "${JPEEK}" --help

locale
