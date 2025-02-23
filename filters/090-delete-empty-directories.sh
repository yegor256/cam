#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

home=$1
temp=$2

list=${temp}/deleted-empty-directories.txt
mkdir -p "$(dirname "${list}")"
touch "${list}"

while true; do
    slice=${temp}/empty-directories-to-delete.txt
    find "${home}" -mindepth 1 -type d -empty -print > "${slice}"
    if [ ! -s "${slice}" ]; then
        break
    fi
    while IFS= read -r dir; do
        rm -r "${dir}"
        echo "${dir}" >> "${list}"
    done < "${slice}"
done

total=$(wc -l < "${list}" | xargs)
if [ "${total}" -eq 0 ]; then
    printf "There were no empty directories"
else
    printf "%'d empty directories were deleted" "${total}"
fi
