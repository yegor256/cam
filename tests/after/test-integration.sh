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

stdout=$2

{
    set -x
    make clean "TARGET=${TARGET}"
    repo=yegor256/tojos
    log=$(make "TARGET=${TARGET}" "REPO=${repo}")
    echo "${log}"
    echo "${log}" | grep "Using one repo: yegor256/tojos"
    echo "${log}" | grep "No repo directories inside"
    echo "${log}" | grep "Cloned 1 repositories"
    echo "${log}" | grep "All 1 repositories checked"
    echo "${log}" | grep "All 1 repositories passed through jPeek"
    echo "${log}" | grep "All metrics calculated"
    echo "${log}" | grep "All metrics aggregated"
    echo "${log}" | grep "PDF report generated"
    echo "${log}" | grep "ZIP archive"
    echo "${log}" | grep "SUCCESS"
    echo "${log}" | grep -v "Failed to collect"
    test -d "${TARGET}"
    for f in start.txt hashes.csv report.pdf repositories.csv; do
        test -f "${TARGET}/${f}"
    done
    test "$(find "${TARGET}" -maxdepth 1 | wc -l | xargs)" = 10
    test -f "${TARGET}/data/${repo}/NCSS.csv"
    test -f "${TARGET}/data/${repo}/NHD.csv"
    test -f "${TARGET}/data/${repo}/SCOM-cvc.csv"
    test -f "${TARGET}/data/NCSS.csv"
    test -f "${TARGET}/data/NHD.csv"
    test -f "${TARGET}/data/SCOM-cvc.csv"
    test -d "${TARGET}/measurements/${repo}/src/main/java"
    test -d "${TARGET}/temp/jpeek/all/${repo}"
    test -d "${TARGET}/temp/jpeek/cvc/${repo}"
    test -f "${TARGET}/temp/reports/010-delete-non-java-files.sh.tex"
    test -f "${TARGET}/temp/pdf-report/report.tex"
    test -f "${TARGET}"/*.zip
    if grep "NaN" "${TARGET}/data/${repo}/NHD.csv"; then
        echo "NaN found in jpeek report"
        exit 1
    fi
    set +x
} > "${stdout}" 2>&1
echo "👍🏻 A full package processed correctly"
