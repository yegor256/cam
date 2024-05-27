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

csv=${TARGET}/foo.csv
tex=${TARGET}/foo.tex

{
    rm -f "${csv}"
    msg=$("${LOCAL}/steps/discover-repos.rb" --dry --pause=0 --total=3 --page-size=1 --min-stars=100 --max-stars=1000 "--csv=${csv}"  "--tex=${tex}")
    echo "${msg}"
    echo "${msg}" | grep "Found 1 good repositories in page #0"
    echo "${msg}" | grep "Found 3 total repositories in GitHub"
    test -e "${csv}"
    test -s "${tex}"
    test "$(wc -l < "${csv}" | xargs)" = '4'
    test "$(head -1 "${csv}" | tr "," "\n" | wc -l | xargs)" = '9'
} > "${stdout}" 2>&1
echo "👍🏻 Small repositories discovery test is succeed"

{
    rm -f "${csv}"
    msg=$("${LOCAL}/steps/discover-repos.rb" --dry --pause=0 --total=35 --page-size=30 --min-stars=100 --max-stars=1000 "--csv=${csv}"  "--tex=${tex}")
    echo "${msg}"
    echo "${msg}" | grep "Found 60 total repositories in GitHub"
    echo "${msg}" | grep "We will use only the first 35 repositories"
    test -e "${csv}"
    test -s "${tex}"
    test "$(wc -l < "${csv}" | xargs)" = '36'
    test "$(head -1 "${csv}" | tr "," "\n" | wc -l | xargs)" = '9'
} > "${stdout}" 2>&1
echo "👍🏻 Medium repositories discovery test is succeed"
