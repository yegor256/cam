#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    msg=$("${LOCAL}/filters/080-delete-symlinks.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "There were no symlinks"
} > "${stdout}" 2>&1
echo "👍🏻 An empty directory didn't crash it"

{
    link="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /a/b/c/Foo.java"
    mkdir -p "$(dirname "${link}")"
    file="${temp}/x/y- ;/dir (with) ; ' _ l/Bar.java"
    mkdir -p "$(dirname "${file}")"
    echo > "${file}"
    ln -s "${file}" "${link}"
    ln -s "${file}" "${temp}/another-link"
    msg=$("${LOCAL}/filters/080-delete-symlinks.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "2 symlinks were deleted"
    test ! -e "${link}"
    test -e "${file}"
} > "${stdout}" 2>&1
echo "👍🏻 A few symlinks were deleted"
