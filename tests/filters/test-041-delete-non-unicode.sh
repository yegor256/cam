#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2024 Timur Harin
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
    mkdir -p "${temp}/foo"
    touch "${temp}/foo/utf8_file.java"
    touch "${temp}/foo/non_utf8_file.java"
    touch "${temp}/foo/other_file.txt"
    echo -e "public class Test {\n\tpublic static void main(String[] args) {\n\t\tSystem.out.println(\"Hello, world!\");\n\t}\n}" > "${temp}/foo/utf8_file.java"
    echo -e "public class Test {\n\tpublic static void main(String[] args) {\n\t\tSystem.out.println(\"Hello, world!\");\n\t}\n}" | iconv -c -t ISO-8859-1 > "${temp}/foo/non_utf8_file.java"
    msg=$("${LOCAL}/filters/delete-non-utf8-java-files.sh" "${temp}/foo" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "1 non-UTF-8 encoded .java files out of 2 were deleted"
    test ! -e "${temp}/foo/non_utf8_file.java"
    test -e "${temp}/foo/utf8_file.java"
    test -e "${temp}/temp/filter-lists/non-utf8-java-files.txt"
    test "$(wc -l < "${temp}/temp/filter-lists/non-utf8-java-files.txt" | xargs)" = 1
} > "${stdout}" 2>&1

echo "👍🏻 Non-UTF-8 encoded Java file was deleted"