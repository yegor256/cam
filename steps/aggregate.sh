#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

start=$(date +%s%N)

metrics=$(find "${TARGET}/measurements" -type f -name '*.m.*' -print | sed "s|^.*\.\(.*\)$|\1|" | sort | uniq | tr '\n' ' ')
echo "All $(echo "${metrics}" | wc -w | xargs) metrics (in alphanumeric order): ${metrics}"

repos=${TARGET}/temp/repos-to-aggregate.txt
mkdir -p "$(dirname "${repos}")"
find "${TARGET}/measurements" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'realpath --relative-to="${1}" "$2"' _ "${TARGET}/measurements" {} \; > "${repos}"
total=$(wc -l < "${repos}" | xargs)

jobs=${TARGET}/temp/jobs/aggregate-jobs.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

declare -i repo=0
sh="$(dirname "$0")/aggregate-repo.sh"
while IFS= read -r r; do
    repo=$((repo+1))
    printf "%s %s %s %s %s\n" "${sh@Q}" "${r@Q}" "${repo@Q}" "${total@Q}" "${metrics@Q}" >> "${jobs}"
done < "${repos}"
"${LOCAL}/help/parallel.sh" "${jobs}"
wait

mkdir -p "${TARGET}/data"
rm -rf "${TARGET}/data/*.csv"
all=${TARGET}/data/all.csv
printf "repository,file" >> "${all}"
echo -n "${metrics}" | while IFS= read -r a; do
    printf ',%s' "${a}" >> "${all}"
done
printf "\n" >> "${all}"

echo "All $(wc -l "${all}" | xargs) projects aggregated$("${LOCAL}/help/tdiff.sh" "${start}")"
printf "\n"

jobs=${TARGET}/temp/jobs/aggregate-join-jobs.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"
declare -i repo=0
sh="$(dirname "$0")/aggregate-join.sh"
repos=${TARGET}/temp/repos-to-join.txt
mkdir -p "$(dirname "${repos}")"
find "${TARGET}/data" -maxdepth 2 -mindepth 2 -type d -print > "${repos}"
while IFS= read -r d; do
    r=$(realpath --relative-to="${TARGET}/data" "${d}" )
    repo=$((repo+1))
    printf "%s %s %s %s %s\n" "${sh@Q}" "${r@Q}" "${d@Q}" "${repo@Q}" "${total@Q}" >> "${jobs}"
done < "${repos}"
"${LOCAL}/help/parallel.sh" "${jobs}"
wait

mkdir -p "${TARGET}/data/aggregation"
f_jobs=${TARGET}/temp/jobs/aggregate-function-jobs.txt
rm -rf "${f_jobs}"
mkdir -p "$(dirname "${f_jobs}")"
touch "${f_jobs}"

for metric in ${metrics}; do
    metric_file="${TARGET}/data/${metric}.csv"
    if [[ -f "${metric_file}" ]]; then
        output_folder="${TARGET}/data/aggregation"
        for sh_script in "${LOCAL}/steps/aggregation-functions/"*.sh; do
            if [[ -f "${sh_script}" ]]; then
                printf "%s %s %s %s\n" "${sh_script@Q}" "${metric_file}" "${output_folder@Q}" "${metric@Q}" >> "${f_jobs}"
            fi
        done
    fi
done
"${LOCAL}/help/parallel.sh" "${f_jobs}"
wait

echo "All metrics aggregated and joined in ${total} repositories$("${LOCAL}/help/tdiff.sh" "${start}")"
