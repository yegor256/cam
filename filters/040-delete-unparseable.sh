#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

home=$1
temp=$2

list=${temp}/filter-lists/unparseable-files.txt
if [ -e "${list}" ]; then
    exit
fi

mkdir -p "$(dirname "${list}")"
touch "${list}"

jobs=${temp}/jobs/delete-unparseable.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

candidates=${temp}/files-to-parse.txt
mkdir -p "$(dirname "${candidates}")"
find "${home}" -type f -name '*.java' -print > "${candidates}"
py=${LOCAL}/filters/delete-unparseable.py
while IFS= read -r f; do
    printf "python3 %s %s %s\n" "${py@Q}" "${f@Q}" "${list@Q}" >> "${jobs}"
done < "${candidates}"
"${LOCAL}/help/parallel.sh" "${jobs}"
wait

total=$(wc -l < "${candidates}" | xargs)
if [ -s "${list}" ]; then
    printf "%'d files out of %'d with an unparseable Java syntax were deleted" \
        "$(wc -l < "${list}" | xargs)" "${total}"
else
    printf "No files out of %'d had an unparseable Java syntax" \
        "${total}"
fi
