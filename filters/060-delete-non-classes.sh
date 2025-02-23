#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

home=$1
temp=$2

list=${temp}/filter-lists/non-class-files.txt
if [ -e "${list}" ]; then
    exit
fi

mkdir -p "$(dirname "${list}")"
touch "${list}"

jobs=${temp}/jobs/delete-non-classes.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

candidates=${temp}/classes-to-challenge.txt
mkdir -p "$(dirname "${candidates}")"
find "${home}" -type f -name '*.java' -print > "${candidates}"
py=${LOCAL}/filters/delete-non-classes.py
while IFS= read -r f; do
    printf "python3 %s %s %s\n" "${py@Q}" "${f@Q}" "${list@Q}" >> "${jobs}"
done < "${candidates}"
"${LOCAL}/help/parallel.sh" "${jobs}"
wait

total=$(wc -l < "${candidates}" | xargs)
if [ -s "${list}" ]; then
    printf "%'d files out of %'d with interfaces or enums (instead of classes) inside were deleted" \
        "$(wc -l < "${list}" | xargs)" "${total}"
else
    printf "All %d files are Java classes, nothing to delete" \
        "${total}"
fi
