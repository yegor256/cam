#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    list=${temp}/temp/filter-lists/test-files.txt
    java="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /FooTest.java"
    mkdir -p "$(dirname "${java}")"
    echo "class FooTest {}" > "${java}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/030-delete-tests.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "1 files out of 2 with \\\ff{Test} or \\\ff{ITCase} suffixes were deleted"
    test ! -e "${java}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 1
} > "${stdout}" 2>&1
echo "👍🏻 A Java test file was deleted"
