#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
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

home=$1
temp=$2

list="${temp}/non-class-files.txt"
if [ -e "${list}" ]; then
    echo "Non-class files have already been deleted"
    exit
fi

touch "${list}"

candidates="${temp}/classes-to-challenge.txt"
find "${home}" -type f -name '*.java' -print > "${candidates}"
while IFS= read -r f; do
    if ! python3 -c "
import sys
import javalang
with open('${f}') as f:
    raw = javalang.parse.parse(f.read())
    tree = raw.filter(javalang.tree.ClassDeclaration)
    tree = list(value for value in tree)
    if not tree:
        exit(1)
"; then echo "${f}" >> "${list}"; echo "Not a class: ${f}"; rm "${f}"; fi
done < "${candidates}"

if [ -s "${list}" ]; then
    echo "There were $(wc -l < "${candidates}") files total.
    $(wc -l < "${list}") of them were not Java classes but interfaces or enums,
    that's why were deleted."
else
    echo "All $(wc -l < "${candidates}") files are Java classes,
    nothing to delete"
fi
