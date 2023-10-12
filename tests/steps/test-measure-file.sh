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

java="${temp}/Foo(xls;)';a привет '\".java"
cat > "${java}" <<EOT
class Foo extends Boo implements Bar {
    // This is static
    private static int X = 1;
    private String z;

    Foo(String zz) {
        this.z = zz;
    }
}
EOT
msg=$("${LOCAL}/steps/measure-file.sh" "${java}" "${temp}/m")
echo "${msg}" >> "${stdout}"
test "$(echo "${msg}" | grep -c "sum=0")" = 0
test "$(cat "${temp}/m.loc")" = "7"
test "$(cat "${temp}/m.comments")" = "1"
test "$(cat "${temp}/m.cc")" = "1"
test "$(cat "${temp}/m.ncss")" = "5"
test "$(cat "${temp}/m.smtds")" = "0"
test "$(cat "${temp}/m.mtds")" = "0"
test "$(cat "${temp}/m.ctors")" = "1"
test "$(cat "${temp}/m.extnds")" = "1"
test "$(cat "${temp}/m.impls")" = "1"
test "$(cat "${temp}/m.final")" = "0"
test "$(cat "${temp}/m.blanks")" = "1"
echo "👍🏻 Single file measured correctly"
