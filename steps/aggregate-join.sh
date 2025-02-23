#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
