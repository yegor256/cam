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
    empty="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /a/b/c"
    mkdir -p "${empty}"
    full="${temp}/x/ ; 'w' \"nx\" /f/d/k"
    mkdir -p "${full}"
    java=${full}/Foo.java
    touch "${java}"
    msg=$("${LOCAL}/filters/090-delete-empty-directories.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "6 empty directories were deleted"
    test ! -e "${empty}"
    test -e "${full}"
    test -e "${java}"
} > "${stdout}" 2>&1
echo "👍🏻 A empty directory was deleted"

{
    mkdir -p "${temp}/bar/a/b/c/d/e/f"
    msg=$("${LOCAL}/filters/090-delete-empty-directories.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "13 empty directories were deleted"
    test ! -e "${temp}/bar"
} > "${stdout}" 2>&1
echo "👍🏻 All empty directories deleted recursively"
