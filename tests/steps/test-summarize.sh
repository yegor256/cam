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
    echo "${TARGET}"
    rm -rf "${TARGET}/data"
    rm -rf "${TARGET}/measurements"
    rm -rf "${TARGET}/summary"
    rm -rf "${TARGET}/temp"
    dir1="${TARGET}/measurements/repo1"
    mkdir -p "${dir1}"
    "${LOCAL}/steps/summarize.sh"
    test -z "$(ls -A "${TARGET}/data/summary")"
} > "${stdout}" 2>&1
echo "👍🏻 Summarization step handled empty repository correctly"

{
    rm -rf "${TARGET}/data"
    rm -rf "${TARGET}/measurements"
    rm -rf "${TARGET}/summary"
    rm -rf "${TARGET}/temp"
    dir1="${TARGET}/measurements/repo1"
    mkdir -p "${TARGET}/temp"
    touch "${TARGET}/temp/repos-to-aggregate.txt"
    echo "repo1" >> "${TARGET}/temp/repos-to-aggregate.txt"
    mkdir -p "${dir1}"
    echo "50" > "${dir1}/file1.m.LOC"
    echo "100" > "${dir1}/file2.m.LOC"
    echo "10" > "${dir1}/file1.m.CYC"
    echo "20" > "${dir1}/file2.m.CYC"
    "${LOCAL}/steps/summarize.sh"
    test -e "${TARGET}/data/summary/LOC.csv"
    test -e "${TARGET}/data/summary/CYC.csv"
    grep "repo1,2,150" < "${TARGET}/data/summary/LOC.csv"
    grep "repo1,2,30" < "${TARGET}/data/summary/CYC.csv"
} > "${stdout}" 2>&1
echo "👍🏻 Summarization step handled multiple metrics correctly"


{
    rm -rf "${TARGET}/data"
    rm -rf "${TARGET}/measurements"
    rm -rf "${TARGET}/summary"
    rm -rf "${TARGET}/temp"
    dir1="${TARGET}/measurements/repo1"
    mkdir -p "${TARGET}/temp"
    touch "${TARGET}/temp/repos-to-aggregate.txt"
    echo "repo1" >> "${TARGET}/temp/repos-to-aggregate.txt"
    echo "repo2" >> "${TARGET}/temp/repos-to-aggregate.txt"
    mkdir -p "${dir1}"
    echo "50" > "${dir1}/file1.m.LOC"
    echo "100" > "${dir1}/file2.m.LOC"
    echo "10" > "${dir1}/file1.m.CYC"
    dir2="${TARGET}/measurements/repo2"
    mkdir -p "${dir2}"
    echo "25" > "${dir2}/file1.m.LOC"
    "${LOCAL}/steps/summarize.sh"
    test -e "${TARGET}/data/summary/LOC.csv"
    grep "repo1,2,150" < "${TARGET}/data/summary/LOC.csv"
    grep "repo2,1,25" < "${TARGET}/data/summary/LOC.csv"
    test -e "${TARGET}/data/summary/CYC.csv"
    grep "repo1,1,10" < "${TARGET}/data/summary/CYC.csv"
    if grep "repo2" < "${TARGET}/data/summary/CYC.csv"; then
        exit 1
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Summarization step handled mixed metrics across repositories correctly"