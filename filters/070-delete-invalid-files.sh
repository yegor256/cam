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

home=$1
temp=$2

list=${temp}/filter-lists/invalid-files.txt
if [ -e "${list}" ]; then
    exit
fi

mkdir -p "$(dirname "${list}")"
touch "${list}"

jobs=${temp}/jobs/delete-invalid-files.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

candidates=${temp}/classes-to-filter.txt
mkdir -p "$(dirname "${candidates}")"
find "${home}" -type f -name '*.java' -print > "${candidates}"
py=${LOCAL}/filters/delete-invalid-files.py
while IFS= read -r f; do
    printf "python3 %s %s %s\n" "${py@Q}" "${f@Q}" "${list@Q}" >> "${jobs}"
done < "${candidates}"
"${LOCAL}/help/parallel.sh" "${jobs}"
wait

total=$(wc -l < "${candidates}" | xargs)
if [ -s "${list}" ]; then
    printf "%'d files out of %'d with more than one Java class inside were deleted" \
        "$(wc -l < "${list}")" "${total}"
else
    if [ "${total}" -eq 0 ]; then
        printf "There were no Java classes, nothing to delete"
    else
        printf "All %'d files are Java classes, nothing to delete" \
            "${total}"
    fi
fi
