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
    grep "NoOA 2 " "${temp}/stdout"
    grep "NoSA 2 " "${temp}/stdout"
    grep "NoCC 0 " "${temp}/stdout"
    grep "NoOM 3 " "${temp}/stdout"
    grep "NoII 2 " "${temp}/stdout"
    grep "NAPC 1 " "${temp}/stdout"
    grep "NoTP 1 " "${temp}/stdout"
    grep "Final 1 " "${temp}/stdout"
    grep "NoCA 1 " "${temp}/stdout"
    grep "PVN 2.75 " "${temp}/stdout"
    grep "MxPVN 6 " "${temp}/stdout"
    grep "MnPVN 1 " "${temp}/stdout"
    grep "PCN 1" "${temp}/stdout"
    grep "MHF 1.0 " "${temp}/stdout"
    grep "SMHF 0 " "${temp}/stdout"
    grep "AHF 0.25 " "${temp}/stdout"
    grep "SAHF 0.0 " "${temp}/stdout"
    grep "NoMP 0 " "${temp}/stdout"
    grep "NoSMP 0 " "${temp}/stdout"
    grep "MxNOMP 0 " "${temp}/stdout"
    grep "MxNOSMP 0 " "${temp}/stdout"
    grep "NOM 0 " "${temp}/stdout"
    grep "NOP 0 " "${temp}/stdout"
    grep "NULLs 0 " "${temp}/stdout"
    grep "DOER 0.5 " "${temp}/stdout"
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
    grep "NULLs 1 " "${temp}/stdout"
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
