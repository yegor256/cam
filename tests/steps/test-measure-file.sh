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

temp=$1
stdout=$2

{
    java="${temp}/Foo(xls;)';a привет '\".java"
    cat > "${java}" <<EOT
    class Foo extends Boo implements Bar {
        // This is static
        private static int X = 1;
        private String z;

        Foo(String zz) {
            this.z = zz;
        }
        private final boolean boom() { return true; }
    }
EOT
    msg=$("${LOCAL}/steps/measure-file.sh" "${java}" "${temp}/m1")
    echo "${msg}"
    set -x
    test "$(echo "${msg}" | grep -c "sum=0")" = 0
    all=$(find "${temp}" -name 'm1.*' -type f -exec basename {} \;)
    test "$(echo "${all}" | wc -l | xargs)" = "38"
    echo "${all}" | sort | while IFS= read -r m; do
        metric=${m//m\./}
        echo "${metric}: $(cat "${temp}/${m}")"
    done
    test "$(cat "${temp}/m1.loc")" = "8"
    test "$(cat "${temp}/m1.nocl")" = "1"
    test "$(cat "${temp}/m1.cc")" = "1"
    test "$(cat "${temp}/m1.ncss")" = "7"
    test "$(cat "${temp}/m1.nocm")" = "0"
    test "$(cat "${temp}/m1.noom")" = "1"
    test "$(cat "${temp}/m1.nocc")" = "1"
    test "$(cat "${temp}/m1.napc")" = "1"
    test "$(cat "${temp}/m1.noii")" = "1"
    test "$(cat "${temp}/m1.notp")" = "0"
    test "$(cat "${temp}/m1.final")" = "0"
    test "$(cat "${temp}/m1.nobl")" = "1"
    test "$(cat "${temp}/m1.hsd")" = "6.188"
    test "$(cat "${temp}/m1.hsv")" = "122.624"
    test "$(cat "${temp}/m1.hse")" = "758.735"
    test "$(cat "${temp}/m1.coco")" = "0"
    test "$(cat "${temp}/m1.fout")" = "0"
    test "$(cat "${temp}/m1.LCOM5")" = "0"
    set +x
} > "${stdout}" 2>&1
echo "👍🏻 Single file measured correctly"

{
    java=${temp}/bad.java
    echo "this is not Java, but a broken syntax" > "${java}"
    msg=$("${LOCAL}/steps/measure-file.sh" "${java}" "${temp}/m2")
    echo "${msg}"
    echo "${msg}" | grep "Failed to collect ast.py"
    echo "${msg}" | grep "Failed to collect cyclomatic_complexity.py"
    test -e "${temp}/m2.coco"
    test -e "${temp}/m2.loc"
    test ! -e "${temp}/m2.cc"
} > "${stdout}" 2>&1
echo "👍🏻 Broken syntax measured and error log created"

