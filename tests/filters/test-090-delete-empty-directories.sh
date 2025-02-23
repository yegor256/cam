#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    empty="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /a/b/c"
    mkdir -p "${empty}"
    full="${temp}/x/ ; 'w' \"nx\" /f/d/k"
    mkdir -p "${full}"
    java=${full}/Foo.java
    touch "${java}"
    msg=$("${LOCAL}/filters/090-delete-empty-directories.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "6 empty directories were deleted"
    test ! -e "${empty}"
    test -e "${full}"
    test -e "${java}"
} > "${stdout}" 2>&1
echo "👍🏻 A empty directory was deleted"

{
    mkdir -p "${temp}/bar/a/b/c/d/e/f"
    msg=$("${LOCAL}/filters/090-delete-empty-directories.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "13 empty directories were deleted"
    test ! -e "${temp}/bar"
} > "${stdout}" 2>&1
echo "👍🏻 All empty directories deleted recursively"
