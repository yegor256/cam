#!/usr/bin/env bash
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

repo=$1
dir=$2
pos=$3
total=$4

start=$(date +%s%N)

csvs=$(find "${dir}" -type f -name '*.csv' -maxdepth 1 -exec basename {} \;)

files=$(echo "${csvs}" | wc -l | xargs)
echo "${csvs}" | while IFS= read -r csv; do
    join=${TARGET}/data/${csv}
    rm -rf "${join}"
    mkdir -p "$(dirname "${join}")"
    while IFS= read -r t; do
        if [ ! -e "${join}" ]; then
            printf 'repo,%s\n' "${t}" > "${join}"
        else
            printf '%s,%s\n' "$(echo "${repo}" | "${LOCAL}/help/to-csv.sh")" "${t}" >> "${join}"
        fi
    done < "${dir}/${csv}"
done

echo "${files} metrics added to the CSV aggregate of ${repo} (${pos}/${total})$("${LOCAL}/help/tdiff.sh" "${start}")"
