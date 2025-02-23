#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

start=$(date +%s%N)

echo "Searching for all .java files in ${TARGET}/github (may take some time, stay calm...)"

javas=$(find "${TARGET}/github" -name '*.java' -type f -print)
total=$(echo "${javas}" | wc -l | xargs)
echo "Found ${total} Java files, starting to collect metrics..."

jobs=${TARGET}/temp/jobs/measure-jobs.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

declare -i file=0
sh="$(dirname "$0")/measure-file.sh"
pstart=$(date +%s%N)
echo "${javas}" | while IFS= read -r java; do
    file=$((file+1))
    rel=$(realpath --relative-to="${TARGET}/github" "${java}")
    javam=${TARGET}/measurements/${rel}.m
    if [ -e "${javam}" ]; then
        echo "Metrics already exist for $(basename "${java}") (${file}/${total})"
        continue
    fi
    printf "%s %s %s %s %s\n" "${sh@Q}" "${java@Q}" "${javam@Q}" "${file@Q}" "${total@Q}" >> "${jobs}"
    if [ "${file: -4}" = '0000' ]; then
        echo "Prepared ${file} jobs out of ${total}$("${LOCAL}/help/tdiff.sh" "${pstart}")..."
        pstart=$(date +%s%N)
    fi
done

"${LOCAL}/help/parallel.sh" "${jobs}"
wait

echo "All metrics calculated in ${total} files in $(nproc) threads$("${LOCAL}/help/tdiff.sh" "${start}")"
