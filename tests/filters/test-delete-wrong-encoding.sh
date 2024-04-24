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
    javaTemp="${temp}/Foo1.java.temp"
    echo "interface Foo {}" > "${javaTemp}"
    java="${temp}/Foo1.java"
    echo "" > "${java}"
    iconv -f ASCII -t UTF-16 "${javaTemp}" > "${java}"
    "${LOCAL}/filters/delete-wrong-encoding.py" "${java}" "${temp}/deleted.txt"
    test ! -e "${java}"
    grep "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a UTF-16 encoding deleted correctly"

{
    javaTemp="${temp}/Foo2.java.temp"
    echo "interface Foo {}" > "${javaTemp}"
    java="${temp}/Foo2.java"
    echo "" > "${java}"
    iconv -f ASCII -t UTF-32 "${javaTemp}" > "${java}"
    "${LOCAL}/filters/delete-wrong-encoding.py" "${java}" "${temp}/deleted.txt"
    test ! -e "${java}"
    grep "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a UTF-32 encoding deleted correctly"

{
    java="${temp}/Foo3.java"
    echo "interface Foo {}" > "${java}"
    "${LOCAL}/filters/delete-wrong-encoding.py" "${java}" "${temp}/deleted.txt"
    test -e "${java}"
    grep -v "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a UTF-8 encoding was not deleted"

{
    if ! "${LOCAL}/filters/delete-wrong-encoding.py" > "${temp}/message"; then
        grep "Usage: python delete-wrong-encoding.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi
    if ! "${LOCAL}/filters/delete-wrong-encoding.py" "${java}" > "${temp}/message"; then
        grep "Usage: python delete-wrong-encoding.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi
    if ! "${LOCAL}/filters/delete-wrong-encoding.py" "${java}" "${temp}/stdout" "${temp}/stdout" > "${temp}/message"; then
        grep "Usage: python delete-wrong-encoding.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Usage works correctly"