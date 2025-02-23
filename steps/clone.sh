#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

start=$(date +%s%N)

jobs=${TARGET}/temp/jobs/clone-jobs.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

repos="${TARGET}/temp/repositories.txt"
mkdir -p "$(dirname "${repos}")"
tail -n +2 "${TARGET}/repositories.csv" > "${repos}"
total=$(wc -l < "${repos}" | xargs)

"${LOCAL}/help/assert-tool.sh" git --version

declare -i repo=0
sh="$(dirname "$0")/clone-repo.sh"
while IFS=',' read -r r tag tail; do
    repo=$((repo+1))
    if [ -z "${tag}" ]; then
      tag='master';
    fi
    if [ "${tag}" = '.' ]; then
      tag='master';
    fi
    if [ -e "${TARGET}/github/${r}" ]; then
        echo "${r}: Git repo is already here (${tail})"
    else
        printf "%s %s %s %s %s\n" "${sh@Q}" "${r@Q}" "${tag@Q}" "${repo@Q}" "${total@Q}" >> "${jobs}"
    fi
done < "${repos}"

"${LOCAL}/help/parallel.sh" "${jobs}" 8
wait

echo "Cloned ${total} repositories in $(nproc) threads$("${LOCAL}/help/tdiff.sh" "${start}")"
