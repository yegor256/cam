#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

home=$1
temp=$2

list=${temp}/deleted-symlinks.txt
mkdir -p "$(dirname "${list}")"
touch "${list}"

while true; do
    slice=${temp}/symlinks-to-delete.txt
    find "${home}" -mindepth 1 -type l -print > "${slice}"
    if [ ! -s "${slice}" ];then
      break;
    fi
    while IFS= read -r link; do
        rm "${link}"
        echo "${link}" >> "${list}"
    done < "${slice}"
done

total=$(wc -l < "${list}" | xargs)
if [ "${total}" -eq 0 ]; then
    printf "There were no symlinks"
else
    printf "%'d symlinks were deleted" "${total}"
fi
