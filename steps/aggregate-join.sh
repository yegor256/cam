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

# This script is executed for every repository that look like `data/<org>/<repo>` directories.
# The script should find all `.csv` files available and join them with the
# files in the `data/` directory. For example, the content of the `data/yegor256/jaxec/LCOM5.csv` file
# will be appended to the content of the `data/LCOM5.csv` file.
#
# It is expected that the content of the "data/yegor256/jaxec/LCOM5.csv" looks like this (the first
# line is the CSV header):
#
# ```
# java_file,LCOM5
# /src/main/java/foo/Hello.java,32
# /src/main/java/bar/test/Another.java,14
# ```
#
# The content of the "data/LCOM5.csv" file should look like this (again, the first line
# is the CSV header):
#
# ```
# repo,java_file,LCOM5
# yegor256/jaxec,/src/main/java/foo/Hello.java,32
# yegor256/jaxec,/src/main/java/bar/test/Another.java,14
# ```

set -e
set -o pipefail

repo=$1
dir=$2
pos=$3
total=$4

start=$(date +%s%N)

csvs=$(find "${dir}" -type f -name '*.csv' -maxdepth 1 -exec basename {} \;)

echo "${csvs}" | while IFS= read -r csv; do
    join=${TARGET}/data/${csv}
    mkdir -p "$(dirname "${join}")"
    if [ ! -e "${join}" ]; then
        printf 'repo,%s\n' "$(head -1 "${dir}/${csv}")" > "${join}"
    fi
    tail -n +2 "${dir}/${csv}" | while IFS= read -r t; do
        printf '%s,%s\n' "$(echo "${repo}" | "${LOCAL}/help/to-csv.sh")" "${t}" >> "${join}"
    done
done

files=$(echo "${csvs}" | wc -l | xargs)
echo "${files} .csv files of ${repo} joined into data/.csv (${pos}/${total})$("${LOCAL}/help/tdiff.sh" "${start}")"
