#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    list=${temp}/temp/filter-lists/module-info-files.txt
    info="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /module-info.java"
    mkdir -p "$(dirname "${info}")"
    echo "module foo;" > "${info}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/021-delete-module-info.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "1 files named as \\\ff{module-info.java} were deleted"
    test ! -e "${info}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 1
} > "${stdout}" 2>&1
echo "👍🏻 A module-info.java file was deleted"
