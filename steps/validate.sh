#!/bin/bash
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
set -e
set -o pipefail

repo=$(find "${TARGET}/github" -maxdepth 2 -mindepth 2 -type d -exec realpath --relative-to="${TARGET}/github" {} \; | head -1)
echo "Found ${repo} repository for validating"

test -d "${TARGET}"
for f in start.txt hashes.csv report.pdf repositories.csv; do
    test -f "${TARGET}/${f}"
done

test -f "${TARGET}/data/${repo}/ncss.csv"
test -f "${TARGET}/data/${repo}/NHD.csv"
test -f "${TARGET}/data/${repo}/SCOM-cvc.csv"
test -f "${TARGET}/data/ncss.csv"
test -f "${TARGET}/data/NHD.csv"
test -f "${TARGET}/data/SCOM-cvc.csv"
test -d "${TARGET}/jpeek/${repo}/src/main/java"
test -d "${TARGET}/measurements/${repo}/src/main/java"
test -d "${TARGET}/temp/jpeek/all/${repo}"
test -d "${TARGET}/temp/jpeek/cvc/${repo}"
test -f "${TARGET}/temp/reports/01-delete-non-java-files.sh.tex"
test -f "${TARGET}/temp/pdf-report/report.tex"
test -f "${TARGET}"/*.zip

if cat "${TARGET}/data/${repo}/NHD.csv" | grep "NaN"; then
    echo "NaN found in jpeek report"
    exit 1
fi

echo -e "ALL CLEAN!"
