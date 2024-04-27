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

list=${temp}/temp/filter-lists/invalid-files.txt

{
    java="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /Foo.java"
    mkdir -p "$(dirname "${java}")"
    echo "class Foo{} class Bar{}" > "${java}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/070-delete-invalid-files.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "1 files out of 1 with more than one Java class inside were deleted"
    test ! -e "${java}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 1
} > "${stdout}" 2>&1
echo "👍🏻 An invalid Java file was deleted"

{
    rm -f "${list}"
    mkdir -p "${temp}/empty"
    msg=$("${LOCAL}/filters/070-delete-invalid-files.sh" "${temp}/empty" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "There were no Java classes, nothing to delete"
} > "${stdout}" 2>&1
echo "👍🏻 A empty directory didn't fail the script"

{
    if ! "${LOCAL}/filters/delete-invalid-files.py" > "${temp}/message"; then
        grep "Usage: python delete-invalid-files.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi

    if ! "${LOCAL}/filters/delete-invalid-files.py" "${java}" > "${temp}/message"; then
        grep "Usage: python delete-invalid-files.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi

    if ! "${LOCAL}/filters/delete-invalid-files.py" "${java}" "${temp}/stdout" "${temp}/stdout" > "${temp}/message"; then
        grep "Usage: python delete-invalid-files.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Usage works correctly"
