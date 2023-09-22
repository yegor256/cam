#!/bin/bash
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
list=${temp}/temp/filter-lists/files-with-long-lines.txt

echo "some text in the file" > "${temp}/Foo.java"
rm -f "${list}"
msg=$("${LOCAL}/filters/05-delete-long-lines.sh" "${temp}" "${temp}/temp")
echo "${msg}" | grep "no files among 1 total" >/dev/null
test -e "${temp}/Foo.java"
test -e "${list}"
test "$(wc -l < "${list}" | xargs)" = 0
echo "👍🏻 A Java file with short lines wasn't deleted"

printf 'a%.0s' {1..5000} > "${temp}/Foo.java"
rm -f "${list}"
msg=$("${LOCAL}/filters/05-delete-long-lines.sh" "${temp}" "${temp}/temp")
echo "${msg}" | grep "1 of them had at least one line longer than 1024 characters" >/dev/null
test ! -e "${temp}/Foo.java"
test -e "${list}"
test "$(wc -l < "${list}" | xargs)" = 1
echo "👍🏻 A Java file with a lone line was deleted"
