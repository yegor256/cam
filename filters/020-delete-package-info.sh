#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

home=$1
temp=$2

list=${temp}/filter-lists/package-info-files.txt
if [ -e "${list}" ]; then
    exit
fi

mkdir -p "$(dirname "${list}")"
find "${home}" -type f -a -name 'package-info.java' -print > "${list}"
while IFS= read -r f; do
    rm -f "${f}"
done < "${list}"

if [ -s "${list}" ]; then
    printf "%'d files named as \\\ff{package-info.java} were deleted" \
        "$(wc -l < "${list}" | xargs)"
else
    printf "There were no files named \\\ff{package-info.java}, that's why nothing was deleted"
fi
