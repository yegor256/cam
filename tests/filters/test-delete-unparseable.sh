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
    java="${temp}/Foo (; '''''\" привет.java"
    echo "this is not Java code at all" > "${java}"
    "${LOCAL}/filters/delete-unparseable.py" "${java}" "${temp}/deleted.txt"
    test ! -e "${java}"
    grep "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a broken syntax inside was deleted correctly"

{
    fixtures=$(realpath "$(dirname "$0")/../../fixtures/filters/unparseable")
    find "${fixtures}" -name '*.java' | while IFS= read -r f; do
        java="${temp}/$(basename "${f}")"
        cp "${f}" "${java}"
        "${LOCAL}/filters/delete-unparseable.py" "${java}" "${temp}/deleted.txt"
        test ! -e "${java}"
        grep "${java}" "${temp}/deleted.txt"
    done
} > "${stdout}" 2>&1
echo "👍🏻 All fixtures with broken syntax were deleted correctly"

{
    java=${temp}/Bar.java
    echo "class привет { --- }" > "${java}"
    "${LOCAL}/filters/delete-unparseable.py" "${java}" "${temp}/deleted.txt"
    test ! -e "${java}"
    grep "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 Another broken syntax inside was deleted correctly"

{
    "${LOCAL}/filters/delete-unparseable.py" "${temp}/file-is-absent.java" "${temp}/deleted.txt"
    grep -v "${temp}/file-is-absent.java" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 Absent file didn't fail the script"
