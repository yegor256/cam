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
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/github/a/b"
    msg=$("${LOCAL}/steps/filter.sh")
    echo "${msg}"
} > "${stdout}" 2>&1
echo "👍🏻 A simple filtering ran smoothly"

{
    rm -rf "${TARGET}/github"
    rm -rf "${TARGET}/temp/reports"
    rm -rf "${TARGET}/temp/filter-lists"
    dir=${TARGET}/github
    mkdir -p "${dir}"
    mkdir -p "${dir}/a/b/.git"
    touch "${dir}/a/b/.git/boom"
    echo "nothing" > "${dir}/package-info.java"
    echo "nothing" > "${dir}/FooTest.java"
    echo "class X {} class Y {} class Z {}" > "${dir}/XYZ.java"
    printf 'class Boom { String x = "a%.0s"; }' {1..5000} > "${dir}/Boom.java"
    ln -s "${dir}/FooTest.java" "${dir}/link.java"
    class="${dir}/a/b/foo - '(weird)'/привет/Foo.java"
        mkdir -p "$(dirname "${class}")"
        echo "class Foo {}" > "${class}"
        echo "nothing" > "${class}.bin"
    interface="${dir}/foo/-- \";'/тук тук/Boom.java"
        mkdir -p "$(dirname "${interface}")"
        echo "interface Boom {}" > "${interface}"
    broken="${dir}/''foo/;;'\"/вот/так/Broken-файл.java"
        mkdir -p "$(dirname "${broken}")"
        echo "broken code совсем" > "${broken}"
    msg=$("${LOCAL}/steps/filter.sh")
    echo "${msg}"
    test "$(echo "${msg}" | grep -c "didn't touch any files")" = 0
    test ! -e "${broken}"
    test ! -e "${interface}"
} > "${stdout}" 2>&1
echo "👍🏻 A more complex filtering ran smoothly"
