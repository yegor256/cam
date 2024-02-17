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
    echo -e 'repo,branch\nfoo/bar,master,44,99\nboom/boom,master\n' > "${TARGET}/repositories.csv"
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/github/boom/boom"
    msg=$("${LOCAL}/steps/unregister.sh")
    echo "${msg}"
    cat "${TARGET}/temp/repositories-before-unregister.txt"
    cat "${TARGET}/repositories.csv"
    grep "boom/boom" "${TARGET}/repositories.csv"
    echo "${msg}" | grep "All 2 repositories checked"
    echo "${msg}" | grep "The clone of foo/bar is absent, unregistered"
    test "$(wc -l < "${TARGET}/repositories.csv" | xargs)" = '2'
} > "${stdout}" 2>&1
echo "👍🏻 A broken repo clone was unregistered"
