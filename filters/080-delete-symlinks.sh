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

list=${temp}/deleted-symlinks.txt
mkdir -p "$(dirname "${list}")"
touch "${list}"

while true; do
    slice=${temp}/symlinks-to-delete.txt
    find "${home}" -mindepth 1 -type l -print > "${slice}"
    if [ ! -s "${slice}" ]; then break; fi
    while IFS= read -r link; do
        rm "${link}"
        echo "${link}" >> "${list}"
    done < "${slice}"
done

total=$(wc -l < "${list}" | xargs)
if [ "${total}" -eq 0 ]; then
    printf "There were no symlinks"
else
    printf "%'d symlinks were deleted" "${total}"
fi

