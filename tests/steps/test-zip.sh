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
    mkdir -p "${TARGET}/something"
    "${LOCAL}/steps/zip.sh"
    test -e "${TARGET}"/*.zip
} > "${stdout}" 2>&1
echo "👍🏻 A zip archive generated correctly"

{
    mkdir -p "${TARGET}/measurements/a/b/baam.m.cloc"
    mkdir -p "${TARGET}/temp/a/b/hello.txt"
    zip=${TARGET}/cam-$(date +%Y-%m-%d).zip
    "${LOCAL}/steps/zip.sh"
    list=$(unzip -l "${zip}")
    echo "${list}"
    test "$(echo "${list}" | grep -c "baam.m.cloc")" = '0'
    test "$(echo "${list}" | grep -c "hello.txt")" = '0'
} > "${stdout}" 2>&1
echo "👍🏻 A zip archive doesn't contain measurements/ and temp/"

{
    mkdir -p "${TARGET}/github/a/b/.git/baam/baam/boom/baam"
    touch "${TARGET}/github/a/b/hello"
    mkdir -p "${TARGET}/github/a/b/legal/.git/place"
    zip=${TARGET}/cam-$(date +%Y-%m-%d).zip
    "${LOCAL}/steps/zip.sh"
    list=$(unzip -l "${zip}")
    echo "${list}"
    echo "${list}" | grep "hello" > /dev/null
    test "$(echo "${list}" | grep -c "boom")" = '0'
    test "$(echo "${list}" | grep -c "place")" = '1'
} > "${stdout}" 2>&1
echo "👍🏻 A zip archive generated without .git directories inside"
