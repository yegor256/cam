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
    rm -rf "${TARGET}/github"
    msg=$("${LOCAL}/filters/001-move-gits-to-temp.sh" "${temp}" "${temp}")
    echo "${msg}"
} > "${stdout}" 2>&1
echo "👍🏻 An empty directory didn't crash it"

{
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/github/foo/bar"
    msg=$("${LOCAL}/filters/001-move-gits-to-temp.sh" "${temp}" "${temp}")
    echo "${msg}"
} > "${stdout}" 2>&1
echo "👍🏻 An empty repo directory didn't crash it"

{
    repo=foo/bar
    mkdir -p "${TARGET}/github/${repo}/.git/test.txt"
    msg=$("${LOCAL}/filters/001-move-gits-to-temp.sh" "${temp}" "${temp}")
    echo "${msg}"
    ls -al "${TARGET}/github/${repo}"
    test ! -e "${TARGET}/github/${repo}/.git"
    ls -al "${temp}/gits/${repo}"
    test -e "${temp}/gits/${repo}/test.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A git repository was moved to temp dir"

{
    first=foo/first
    second=foo/second
    mkdir -p "${TARGET}/github/${first}/.git/test.txt"
    mkdir -p "${TARGET}/github/${second}/.git/test.txt"
    msg=$("${LOCAL}/filters/001-move-gits-to-temp.sh" "${temp}" "${temp}")
    echo "${msg}"
    ls -al "${TARGET}/github/${first}"
    test ! -e "${TARGET}/github/${first}/.git"
    ls -al "${temp}/gits/${second}"
    test -e "${temp}/gits/${second}/test.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A pair of git repositories were moved to temp dir"
