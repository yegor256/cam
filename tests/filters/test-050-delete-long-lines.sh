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

temp=$1
stdout=$2

list=${temp}/temp/filter-lists/files-with-long-lines.txt

{
    java="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /Foo.java"
    mkdir -p "$(dirname "${java}")"
    echo "some text in the file" > "${java}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/050-delete-long-lines.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "No files out of 1 had lines longer "
    test -e "${java}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 0
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with short lines wasn't deleted"

{
    java="${temp}/foo/bb/Привет.java"
    mkdir -p "$(dirname "${java}")"
    printf 'a%.0s' {1..5000} > "${java}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/050-delete-long-lines.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "1 files out of 2 with at least one line longer "
    test ! -e "${java}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 1
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a long line was deleted"

{
    # see https://stackoverflow.com/questions/77169978/how-to-reproduce-awk-warning-invalid-multibyte-data-detected
    java="${temp}/foo/bb/привет/Привет.java"
    mkdir -p "$(dirname "${java}")"
    printf '\xC0\x80' > "${java}"
    rm -f "${list}"
    msg=$(LC_ALL=en_US.UTF-8 "${LOCAL}/filters/050-delete-long-lines.sh" "$(dirname "${java}")" "${temp}/temp" 2>&1)
    test "$(echo "${msg}" | grep -c "Invalid multibyte data detected")" = 0
} > "${stdout}" 2>&1
echo "👍🏻 A non-unicode file didn't cause awk troubles"

{
    java="${temp}/--/empty.java"
    mkdir -p "$(dirname "${java}")"
    touch "${java}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/050-delete-long-lines.sh" "${temp}" "${temp}/temp")
    test -e "${java}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 0
} > "${stdout}" 2>&1
echo "👍🏻 An empty Java file wasn't deleted"

