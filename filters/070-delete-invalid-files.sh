#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

home=$1
temp=$2

list=${temp}/filter-lists/invalid-files.txt
if [ -e "${list}" ]; then
    exit
fi

mkdir -p "$(dirname "${list}")"
touch "${list}"

jobs=${temp}/jobs/delete-invalid-files.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

candidates=${temp}/classes-to-filter.txt
mkdir -p "$(dirname "${candidates}")"
find "${home}" -type f -name '*.java' -print > "${candidates}"
py=${LOCAL}/filters/delete-invalid-files.py
while IFS= read -r f; do
    printf "python3 %s %s %s\n" "${py@Q}" "${f@Q}" "${list@Q}" >> "${jobs}"
done < "${candidates}"
"${LOCAL}/help/parallel.sh" "${jobs}"
wait

total=$(wc -l < "${candidates}" | xargs)
if [ -s "${list}" ]; then
    printf "%'d files out of %'d with more than one Java class inside were deleted" \
        "$(wc -l < "${list}")" "${total}"
else
    if [ "${total}" -eq 0 ]; then
        printf "There were no Java classes, nothing to delete"
    else
        printf "All %'d files are Java classes, nothing to delete" \
            "${total}"
    fi
fi
