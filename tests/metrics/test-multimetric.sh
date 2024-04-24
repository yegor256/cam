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

# To make sure it is installed
multimetric --help >/dev/null

{
    java="${temp}/Foo long 'weird' name (--).java"
    cat > "${java}" <<EOT
    import java.io.File;
    import java.io.IOException;
    class Foo extends Boo implements Bar {
        // This is static
        private static int X = 1;
        private java.io.File z;

        Foo(File zz) throws IOException {
            this.z = zz;
            zz.delete();
        }
        private final boolean boom() { return true; }
    }
EOT
    "${LOCAL}/metrics/multimetric.sh" "${java}" "${temp}/stdout"
    cat "${TARGET}/temp/multimetric.json"
    cat "${temp}/stdout"
    grep "HSD 6.000 " "${temp}/stdout"
    grep "HSE 1133.217 " "${temp}/stdout"
    grep "HSV 188.869 " "${temp}/stdout"
    grep "MIdx 100.000 " "${temp}/stdout"
    grep "FOut 0.000 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly counted a few metrics"
