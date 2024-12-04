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
    repo="foo/bar test ; "
    dir="${TARGET}/measurements/${repo}/a"
    mkdir -p "${dir}"
    touch "${dir}/Foo.java.m"
    echo "42" > "${dir}/Foo.java.m.loc"
    "${LOCAL}/steps/aggregate.sh"
    test -e "${TARGET}/data/${repo}/all.csv"
    test -e "${TARGET}/data/${repo}/loc.csv"
    grep ",42" < "${TARGET}/data/${repo}/loc.csv"
    test -e "${TARGET}/data/all.csv"
    test -e "${TARGET}/data/loc.csv"
    grep ",42" < "${TARGET}/data/loc.csv"
} > "${stdout}" 2>&1
echo "👍🏻 A repo aggregated correctly"

{
    rm -rf "${TARGET}/data"
    rm -rf "${TARGET}/measurements"
    dir1="${TARGET}/measurements/first/a"
    mkdir -p "${dir1}"
    touch "${dir1}/First.java.m"
    echo "42" > "${dir1}/First.java.m.LCOM5"
    dir2="${TARGET}/measurements/second/b"
    mkdir -p "${dir2}"
    touch "${dir2}/Second.java.m"
    echo "7" > "${dir2}/Second.java.m.LCOM5"
    echo "256" > "${dir2}/Second.java.m.NHD"
    echo "10000" > "${dir2}/Second.java.m.loc"
    dir3="${TARGET}/measurements/third/c"
    mkdir -p "${dir3}"
    touch "${dir3}/Third.java.m"
    echo "700" > "${dir3}/Third.java.m.LCOM5"
    "${LOCAL}/steps/aggregate.sh"
    test -e "${TARGET}/data/first/a/LCOM5.csv"
    test -e "${TARGET}/data/first/a/all.csv"
    test -e "${TARGET}/data/second/b/LCOM5.csv"
    test -e "${TARGET}/data/second/b/all.csv"
    grep ",42" < "${TARGET}/data/LCOM5.csv"
} > "${stdout}" 2>&1
echo "👍🏻 A pair of repos aggregated correctly"
