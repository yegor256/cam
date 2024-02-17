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

{
    mkdir -p "${temp}/foo"
    msg=$("${LOCAL}/filters/010-delete-non-java-files.sh" "${temp}/foo" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "nothing was deleted"
} > "${stdout}" 2>&1
echo "👍🏻 An empty directory didn't crash it"

{
    list=${temp}/temp/filter-lists/non-java-files.txt
    png="${temp}/foo/dir (with) _ long & and 'java' \"name\" /test.png"
    mkdir -p "$(dirname "${png}")"
    echo "" > "${png}"
    mkdir -p "$(dirname "${list}")"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/010-delete-non-java-files.sh" "${temp}/foo" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "1 files out of 1 without the \\\ff{.java} extension were deleted"
    test ! -e "${png}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 1
} > "${stdout}" 2>&1
echo "👍🏻 A binary non-Java file was deleted"

