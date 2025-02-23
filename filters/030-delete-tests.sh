#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

home=$1
temp=$2

total=$(find "${home}" -type f | wc -l | xargs)

list=${temp}/filter-lists/test-files.txt
if [ -e "${list}" ]; then
    exit
fi

mkdir -p "$(dirname "${list}")"

{
    find "${home}" -type f -name '*Test.java' -print;
    find "${home}" -type f -name '*ITCase.java' -print;
    find "${home}" -type f -name '*Tests.java' -print;
    find "${home}" -type f -path '**/src/test/java/**/*.java' -print
} > "${list}"
while IFS= read -r f; do
    rm -f "${f}"
done < "${list}"

if [ -s "${list}" ]; then
    printf "%'d files out of %'d with \\\ff{Test} or \\\ff{ITCase} suffixes were deleted" \
        "$(wc -l < "${list}" | xargs)" "${total}"
else
    printf "There were no test files among %d files seen" "${total}"
fi
