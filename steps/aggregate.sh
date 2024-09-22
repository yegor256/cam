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

echo "All metrics aggregated and joined in ${total} repositories$("${LOCAL}/help/tdiff.sh" "${start}")"
