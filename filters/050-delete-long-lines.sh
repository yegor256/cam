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

max=1024

list=${temp}/filter-lists/files-with-long-lines.txt
if [ -e "${list}" ]; then
    exit
fi

mkdir -p "$(dirname "${list}")"
touch "${list}"

candidates=${temp}/files-to-check-line-lengths.txt
find "${home}" -type f -name '*.java' -print > "${candidates}"
while IFS= read -r f; do
    length=$(LC_ALL=C awk '{ print length($0) }' < "${f}" | sort -n | tail -1)
    if [ -z "${length}" ]; then continue; fi
    if [ "${length}" -gt "${max}" ]; then
        echo "${f}" >> "${list}"
        rm "${f}"
    fi
done < "${candidates}"

total=$(wc -l < "${candidates}" | xargs)
if [ -s "${list}" ]; then
    printf "%'d files out of %'d with at least one line longer than %'d characters, which most probably is a symptom of an auto-generated code, were deleted" \
        "$(wc -l < "${list}" | xargs)" "${total}" "${max}"
else
    printf "No files out of %'d had lines longer than %'d characters" \
        "${total}" "${max}"
fi
