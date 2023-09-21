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

list="${temp}/unparseable-files.txt"
if [ -e "${list}" ]; then
    exit
fi

touch "${list}"

jobs=${TARGET}/temp/delete-unparseable.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

candidates="${temp}/files-to-parse.txt"
mkdir -p "$(dirname "${candidates}")"
find "${home}" -type f -name '*.java' -print > "${candidates}"
while read -r f; do
    echo "python3 \"${LOCAL}/filters/delete-unparseable.py\" \"${f}\" \"${list}\" >/dev/null 2>&1" >> "${jobs}"
done < "${candidates}"
uniq "${jobs}" | xargs -I {} -P "$(nproc)" "${SHELL}" -c "{}"
wait

if [ -s "${list}" ]; then
    printf "There were %d files total; %d of them were Java files with broken syntax and that's why were deleted" \
        "$(wc -l < "${candidates}")" \
        "$(wc -l < "${list}")"
else
    printf "There were no files with broken syntax among %d files total" \
        "$(wc -l < "${candidates}")"
fi
