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

csv=${TARGET}/repositories.csv

if [ ! -e "${csv}" ]; then
    echo "Nothing to unregister, the CSV is absent: ${csv}"
    exit
fi

before="${TARGET}/temp/repositories-before-unregister.txt"
mkdir -p "$(dirname "${before}")"
tail -n +2 "${csv}" > "${before}"

head=$(head -1 "${csv}")
rm -f "${csv}"
echo "${head}" > "${csv}"

declare -i total=0
declare -i good=0
while IFS=',' read -r r tag tail; do
    if [ -z "${r}" ]; then continue; fi
    total=$((total+1))
    if [ ! -e "${TARGET}/github/${r}" ]; then
        echo "The clone of ${r} is absent, unregistered"
    else
        printf "%s,%s,%s\n" "${r}" "${tag}" "${tail}" >> "${csv}"
        good=$((good+1))
    fi
done < "${before}"
echo "All ${total} repositories checked, ${good} are good"

