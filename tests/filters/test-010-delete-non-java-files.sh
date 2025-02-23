#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    mkdir -p "${temp}/foo"
    msg=$("${LOCAL}/filters/010-delete-non-java-files.sh" "${temp}/foo" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "nothing was deleted"
} > "${stdout}" 2>&1
echo "👍🏻 An empty directory didn't crash it"

{
    list=${temp}/temp/filter-lists/non-java-files.txt
    png="${temp}/foo/dir (with) _ long & and 'java' \"name\" /test.png"
    mkdir -p "$(dirname "${png}")"
    echo "" > "${png}"
    mkdir -p "$(dirname "${list}")"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/010-delete-non-java-files.sh" "${temp}/foo" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "1 files out of 1 without the \\\ff{.java} extension were deleted"
    test ! -e "${png}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 1
} > "${stdout}" 2>&1
echo "👍🏻 A binary non-Java file was deleted"
