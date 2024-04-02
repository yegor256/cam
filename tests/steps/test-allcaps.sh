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

temp=$1
stdout=$2

{
    java="${temp}/Foo(xls;)';ого привет '\".java"
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
    "${LOCAL}/steps/measure-file.sh" "${java}" "${temp}/m1"
    set -x
    all=$(find "${temp}" -name 'm1.*' -type f -exec basename {} \; | sort)
    expected=$(echo "${all}" | wc -l | xargs)
    actual=$(echo "${all}" | grep -E -c 'm1.([A-Z][A-Za-z0-9]*)+(-cvc)?$' | xargs)
    if [ ! "${actual}" = "${expected}" ]; then
        echo "Exactly ${expected} metrics were expected to be named in AllCaps format, but ${actual} actually were"
        exit 1
    fi
    set +x
} > "${stdout}" 2>&1
echo "👍🏻 All metrics are correctly named in AllCaps format"



