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
    java="${temp}/Foo long 'weird' name (--).java"
    echo "@Demo public final class Foo<T> extends Bar implements Boom, Hello {
        final File a;
        static String Z;
        static float MY_CONSTANT_PI_WITH_LONG_NAME = 3.14159;
        private int camelCase123;
        void x() { }
        int y() { return 0; }
        void camelCaseMethod() { }
    }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    cat "${temp}/stdout"
    grep "nooa 2" "${temp}/stdout"
    grep "nosa 2" "${temp}/stdout"
    grep "noca 1" "${temp}/stdout"
    grep "noom 3" "${temp}/stdout"
    grep "noii 2" "${temp}/stdout"
    grep "napc 1" "${temp}/stdout"
    grep "notp 1" "${temp}/stdout"
    grep "final 1" "${temp}/stdout"
    grep "noca 1" "${temp}/stdout"
    grep "varcomp 2.75" "${temp}/stdout"
    grep "mhf 1.0" "${temp}/stdout"
    grep "smhf 0" "${temp}/stdout"
    grep "ahf 0" "${temp}/stdout"
    grep "sahf 0" "${temp}/stdout"
    grep "nomp 0" "${temp}/stdout"
    grep "nosmp 0" "${temp}/stdout"
    grep "mxnomp 0" "${temp}/stdout"
    grep "mxnosmp 0" "${temp}/stdout"
    grep "nom 0" "${temp}/stdout"
    grep "nop 0" "${temp}/stdout"
    grep "nulls 0" "${temp}/stdout"
    grep "doer 0.5" "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly collected AST metrics"

{
    java="${temp}/Hello.java"
    echo "class Hello {
        String x() { return null; }
        String y() { return \"null\"; }
    }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    cat "${temp}/stdout"
    grep "nulls 1" "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly counted NULL references"

{
    if ! "${LOCAL}/metrics/ast.py" > "${temp}/message"; then
        grep "Usage: python ast.py <path to the .java file> <output file with metrics>" "${temp}/message"
    fi

    if ! "${LOCAL}/metrics/ast.py" "${java}" > "${temp}/message"; then
        grep "Usage: python ast.py <path to the .java file> <output file with metrics>" "${temp}/message"
    fi

    if ! "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout" "${temp}/stdout" > "${temp}/message"; then
        grep "Usage: python ast.py <path to the .java file> <output file with metrics>" "${temp}/message"
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Usage works correctly"
