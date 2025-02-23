#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    list=${temp}/temp/filter-lists/package-info-files.txt
    info="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /package-info.java"
    mkdir -p "$(dirname "${info}")"
    echo "package foo;" > "${info}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/020-delete-package-info.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "1 files named as \\\ff{package-info.java} were deleted"
    test ! -e "${info}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 1
} > "${stdout}" 2>&1
echo "👍🏻 A package-info.java file was deleted"
