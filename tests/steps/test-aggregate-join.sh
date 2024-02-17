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
    repo="foo/bar,1"
    dir="${TARGET}/data/${repo}"
    mkdir -p "${dir}"
    echo -e "java_file,loc\nFoo.java,42\nBar.java,256" > "${dir}/loc.csv"
    msg=$("${LOCAL}/steps/aggregate-join.sh" "${repo}" "${dir}" 1 1)
    echo "${msg}"
    test "$(echo "${msg}" | grep -c "sum=0")" = 0
    test -e "${TARGET}/data/loc.csv"
    grep "repo,java_file,loc" "${TARGET}/data/loc.csv"
    grep "foo/bar\\\\,1,Foo.java,42" "${TARGET}/data/loc.csv"
} > "${stdout}" 2>&1
echo "👍🏻 A data joined correctly"

{
    dir1="${TARGET}/data/first/a"
    mkdir -p "${dir1}"
    dir2="${TARGET}/data/second/b"
    mkdir -p "${dir2}"
    dir3="${TARGET}/data/third/c"
    mkdir -p "${dir3}"
    echo -e "java_file,LCOM5\nFirst.java,42" > "${dir1}/LCOM5.csv"
    echo -e "java_file,LCOM5\nSecond.java,256" > "${dir2}/LCOM5.csv"
    echo -e "java_file,LCOM5\nThird.java,0" > "${dir3}/LCOM5.csv"
    "${LOCAL}/steps/aggregate-join.sh" first/a "${dir1}" 1 1
    "${LOCAL}/steps/aggregate-join.sh" second/b "${dir2}" 1 1
    "${LOCAL}/steps/aggregate-join.sh" third/c "${dir3}" 1 1
    grep "first/a,First.java" "${TARGET}/data/LCOM5.csv"
    grep "second/b,Second.java" "${TARGET}/data/LCOM5.csv"
    grep "third/c,Third.java" "${TARGET}/data/LCOM5.csv"
} > "${stdout}" 2>&1
echo "👍🏻 A data joined into existing file correctly"
