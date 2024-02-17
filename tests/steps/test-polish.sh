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

echo -e 'repo,branch\nfoo/bar,master,44,55' > "${TARGET}/repositories.csv"
rm -rf "${TARGET}/github"
mkdir -p "${TARGET}/github/foo/bar"
msg=$("${LOCAL}/steps/polish.sh")
test -e "${TARGET}/github/foo/bar"
{
    echo "${msg}"
    echo "${msg}" | grep "foo/bar is already here"
} > "${stdout}" 2>&1
echo "👍🏻 A correct directory was not deleted"

touch "${TARGET}/repositories.csv"
rm -rf "${TARGET}/github"
mkdir -p "${TARGET}/github/foo/bar"
msg=$("${LOCAL}/steps/polish.sh")
{
    echo "${msg}"
    echo "${msg}" | grep -v "foo/bar is obsolete and was deleted"
    echo "${msg}" | grep "All 1 repo directories"
} > "${stdout}" 2>&1
echo "👍🏻 An obsolete directory was deleted"

touch "${TARGET}/repositories.csv"
rm -rf "${TARGET}/github"
mkdir -p "${TARGET}/github"
msg=$("${LOCAL}/steps/polish.sh")
{
    echo "${msg}"
    echo "${msg}" | grep "No repo directories"
} > "${stdout}" 2>&1
echo "👍🏻 An empty directory was checked"

TARGET=${TARGET}/dir-is-absent
msg=$("${LOCAL}/steps/polish.sh")
{
    echo "${msg}"
    echo "${msg}" | grep "Nothing to polish, the directory is absent"
} > "${stdout}" 2>&1
echo "👍🏻 An absent directory passed filtering"
