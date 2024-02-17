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

jobs=${TARGET}/temp/jobs/jpeek-jobs.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

repos=$(find "${TARGET}/github" -maxdepth 2 -mindepth 2 -type d -print)
total=$(echo "${repos}" | wc -l | xargs)

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
