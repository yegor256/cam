#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

home=$1
temp=$2

list=${temp}/filter-lists/unparsable-files.txt
if [ -e "${list}" ]; then
    exit
fi

mkdir -p "$(dirname "${list}")"
touch "${list}"

jobs=${temp}/jobs/delete-unparsable.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

candidates=${temp}/files-to-parse.txt
mkdir -p "$(dirname "${candidates}")"
find "${home}" -type f -name '*.java' -print > "${candidates}"
py=${LOCAL}/filters/delete-unparsable.py
while IFS= read -r f; do
    printf "python3 %s %s %s\n" "${py@Q}" "${f@Q}" "${list@Q}" >> "${jobs}"
done < "${candidates}"
"${LOCAL}/help/parallel.sh" "${jobs}"
wait

total=$(wc -l < "${candidates}" | xargs)
if [ -s "${list}" ]; then
    printf "%'d files out of %'d with an unparsable Java syntax were deleted" \
        "$(wc -l < "${list}" | xargs)" "${total}"
else
    printf "No files out of %'d had an unparsable Java syntax" \
        "${total}"
fi
