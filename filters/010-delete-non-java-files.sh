#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

home=$1
temp=$2

total=$(find "${home}" -type f | wc -l)

list=${temp}/filter-lists/non-java-files.txt
if [ -e "${list}" ]; then
    exit
fi

mkdir -p "$(dirname "${list}")"
find "${home}" -type f -not -name '*.java' -print > "${list}"
while IFS= read -r f; do
    rm -f "${f}"
done < "${list}"

if [ -s "${list}" ]; then
    printf "%'d files out of %'d without the \\\ff{.java} extension were deleted" \
        "$(wc -l < "${list}" | xargs)" "${total}"
else
    printf "%'d files were \\\ff{.java} files, nothing was deleted" \
        "${total}"
fi
