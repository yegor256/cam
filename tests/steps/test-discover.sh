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

csv=${TARGET}/repositories.csv

{
    rm -f "${csv}"
    TOTAL=3 "${LOCAL}/steps/discover.sh"
    test -e "${csv}"
    test -s "${TARGET}/temp/repo-details.tex"
    test "$(wc -l < "${csv}" | xargs)" = '4'
} > "${stdout}" 2>&1
echo "👍🏻 A few repositories discovered correctly"

{
    rm -f "${csv}"
    REPO=yegor256/jaxec "${LOCAL}/steps/discover.sh"
    test -e "${csv}"
    test -s "${TARGET}/temp/repo-details.tex"
    test "$(wc -l < "${csv}" | xargs)" = '2'
} > "${stdout}" 2>&1
echo "👍🏻 A single repository discovered correctly"
