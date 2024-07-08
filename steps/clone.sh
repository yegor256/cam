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

jobs=${TARGET}/temp/jobs/clone-jobs.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

repos="${TARGET}/temp/repositories.txt"
mkdir -p "$(dirname "${repos}")"
tail -n +2 "${TARGET}/repositories.csv" > "${repos}"
total=$(wc -l < "${repos}" | xargs)

"${LOCAL}/help/assert-tool.sh" git --version

files() {
    local repo_dir="$1"
    local repo_name="$2"
    local count
    count=$(find "${repo_dir}" \( -path ./.git \) -prune -o -type f | wc -l)
    echo "${repo_name}, ${count}"
}

temp_repo_files="${TARGET}/temp/repo_files.csv"
rm -rf "${temp_repo_files}"

declare -i repo=0
sh="$(dirname "$0")/clone-repo.sh"
while IFS=',' read -r r tag tail; do
    repo=$((repo+1))
    if [ -z "${tag}" ]; then tag='master'; fi
    if [ "${tag}" = '.' ]; then tag='master'; fi
    if [ -e "${TARGET}/github/${r}" ]; then
        echo "${r}: Git repo is already here (${tail})"
        count=$(files "${TARGET}/github/${r}" "${r}")
        echo "${count}" >> "${temp_repo_files}"
    else
        printf "%s %s %s %s %s\n" "${sh@Q}" "${r@Q}" "${tag@Q}" "${repo@Q}" "${total@Q}" >> "${jobs}"
    fi
done < "${repos}"

"${LOCAL}/help/parallel.sh" "${jobs}" 8
wait

cat "${temp_repo_files}" > "${TARGET}/repo_files.csv"

echo "Cloned ${total} repositories in $(nproc) threads$("${LOCAL}/help/tdiff.sh" "${start}")"
