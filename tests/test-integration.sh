#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2023 Yegor Bugayenko
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
    log=$(make "TARGET=${TARGET}" "REPO=yegor256/tojos")
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
    make validate "TARGET=${TARGET}"
    set +x
} > "${stdout}" 2>&1
echo "👍🏻 A full package processed correctly"
