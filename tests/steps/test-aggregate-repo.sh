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
    repo="foo/bar test, ; "
    dir="${TARGET}/measurements/${repo}/a, ; -"
    mkdir -p "${dir}"
    m="Foo,- ;Bar.java.m"
    touch "${dir}/${m}"
    echo ".75" > "${dir}/${m}.nhd"
    echo "42" > "${dir}/${m}.loc"
    msg=$("${LOCAL}/steps/aggregate-repo.sh" "${repo}" 1 1 'loc nhd')
    test "$(echo "${msg}" | grep -c "sum=0")" == 0
    test "$(echo "${msg}" | grep -c "files=0")" == 0
    test -e "${TARGET}/data/${repo}/all.csv"
    grep "/a\\\\, ; -/Foo\\\\,- ;Bar.java,42.000,0.750" "${TARGET}/data/${repo}/all.csv"
    grep "java_file,loc,nhd" "${TARGET}/data/${repo}/all.csv"
    test -e "${TARGET}/data/${repo}/loc.csv"
    grep "java_file,loc" "${TARGET}/data/${repo}/loc.csv"
    grep "/a\\\\, ; -/Foo\\\\,- ;Bar.java,42" "${TARGET}/data/${repo}/loc.csv"
    test -e "${TARGET}/data/${repo}/nhd.csv"
    grep ",42" "${TARGET}/data/${repo}/loc.csv"
} > "${stdout}" 2>&1
echo "👍🏻 A repo aggregated correctly"

{
    repo="dog/cat"
    dir="${TARGET}/data/${repo}"
    mkdir -p "${dir}"
    touch "${dir}/loc.csv"
    msg=$("${LOCAL}/steps/aggregate-repo.sh" "${repo}" 1 1 'loc nhd')
    echo "${msg}" | grep "Not all 2 metrics aggregated"
} > "${stdout}" 2>&1
echo "👍🏻 A partially aggregated repo processed correctly"
