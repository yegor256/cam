#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

start=$(date +%s%N)

jobs=${TARGET}/temp/jobs/jpeek-jobs.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

repos=$(find "${TARGET}/github" -maxdepth 2 -mindepth 2 -type d -print)
total=$(echo "${repos}" | wc -l | xargs)

: > "${TARGET}/temp/jpeek_failure.log"
: > "${TARGET}/temp/jpeek_success.log"
dir=${TARGET}/temp/jpeek/all
mkdir -p "${dir}"

declare -i repo=0
sh="$(dirname "$0")/jpeek-repo.sh"
for d in ${repos}; do
    r=$(realpath --relative-to="${TARGET}/github" "${d}" )
    repo=$((repo+1))
    printf "timeout 1h %s %s %s %s || true\n" "${sh@Q}" "${r@Q}" "${repo@Q}" "${total@Q}" >> "${jobs}"
done

"${LOCAL}/help/parallel.sh" "${jobs}"
wait

done=$(find "${dir}" -maxdepth 2 -mindepth 2 -type d -print | wc -l | xargs)

echo "All ${total} repositories passed through jPeek, ${done} of them produced data, in $(nproc) threads$("${LOCAL}/help/tdiff.sh" "${start}")"
