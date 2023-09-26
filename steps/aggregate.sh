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

start=$(date +%s)

all=$(find "${TARGET}/measurements" -name '*.m.*' -print | sed "s|^.*\.\(.*\)$|\1|" | sort | uniq | tr '\n' ' ')
echo "All $(echo "${all}" | wc -w | xargs) metrics: ${all}"

repos=$(find "${TARGET}/measurements" -maxdepth 2 -mindepth 2 -type d -exec realpath --relative-to="${TARGET}/measurements" {} \;)
total=$(echo "${repos}" | wc -l | xargs)

jobs=${TARGET}/jobs/aggregate-jobs.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

declare -i repo=0
sh="$(dirname "$0")/aggregate-repo.sh"
for r in ${repos}; do
    repo=$((repo+1))
    printf "%s %s %s %s\n" "${sh@Q}" "${r@Q}" "${repo@Q}" "${total@Q}" >> "${jobs}"
done
uniq "${jobs}" | xargs -0 -P "$(nproc)" "${SHELL}" -c
wait

rm -rf "${TARGET}/data/*.csv"
printf "repository,file" >> "${TARGET}/data/all.csv"
for a in ${all}; do
    printf ',%s' "${a}" >> "${TARGET}/data/all.csv"
done
printf "\n" >> "${TARGET}/data/all.csv"

find "${TARGET}/data" -maxdepth 2 -mindepth 2 -type d -print | while read -r d; do
    r=$(realpath --relative-to="${TARGET}/data" "$d" )
    find "${d}" -name '*.csv' -maxdepth 1 -exec basename {} \; | while read -r csv; do
        while read -r t; do
            echo "${r},${t}" >> "${TARGET}/data/${csv}"
        done < "${d}/${csv}"
    done
    echo "${r} metrics added to the CSV aggregate"
done

echo "All metrics aggregated in ${total} repositories in $(nproc) threads in $(echo "$(date +%s) - ${start}" | bc)s"
