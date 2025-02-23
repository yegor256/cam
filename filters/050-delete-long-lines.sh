#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

home=$1
temp=$2

max=1024

list=${temp}/filter-lists/files-with-long-lines.txt
if [ -e "${list}" ]; then
    exit
fi

mkdir -p "$(dirname "${list}")"
touch "${list}"

candidates=${temp}/files-to-check-line-lengths.txt
find "${home}" -type f -name '*.java' -print > "${candidates}"
while IFS= read -r f; do
    length=$(LC_ALL=C awk '{ print length($0) }' < "${f}" | sort -n | tail -1)
    if [ -z "${length}" ]; then
      continue;
    fi
    if [ "${length}" -gt "${max}" ]; then
        echo "${f}" >> "${list}"
        rm "${f}"
    fi
done < "${candidates}"

total=$(wc -l < "${candidates}" | xargs)
if [ -s "${list}" ]; then
    printf "%'d files out of %'d with at least one line longer than %'d characters, which most probably is a symptom of an auto-generated code, were deleted" \
        "$(wc -l < "${list}" | xargs)" "${total}" "${max}"
else
    printf "No files out of %'d had lines longer than %'d characters" \
        "${total}" "${max}"
fi
