#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

list=${temp}/temp/filter-lists/files-with-long-lines.txt

{
    java="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /Foo.java"
    mkdir -p "$(dirname "${java}")"
    echo "some text in the file" > "${java}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/050-delete-long-lines.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "No files out of 1 had lines longer "
    test -e "${java}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 0
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with short lines wasn't deleted"

{
    java="${temp}/foo/bb/Привет.java"
    mkdir -p "$(dirname "${java}")"
    printf 'a%.0s' {1..5000} > "${java}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/050-delete-long-lines.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "1 files out of 2 with at least one line longer "
    test ! -e "${java}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 1
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a long line was deleted"

{
    # see https://stackoverflow.com/questions/77169978/how-to-reproduce-awk-warning-invalid-multibyte-data-detected
    java="${temp}/foo/bb/привет/Привет.java"
    mkdir -p "$(dirname "${java}")"
    printf '\xC0\x80' > "${java}"
    rm -f "${list}"
    msg=$(LC_ALL=en_US.UTF-8 "${LOCAL}/filters/050-delete-long-lines.sh" "$(dirname "${java}")" "${temp}/temp" 2>&1)
    test "$(echo "${msg}" | grep -c "Invalid multibyte data detected")" = 0
} > "${stdout}" 2>&1
echo "👍🏻 A non-unicode file didn't cause awk troubles"

{
    java="${temp}/--/empty.java"
    mkdir -p "$(dirname "${java}")"
    touch "${java}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/050-delete-long-lines.sh" "${temp}" "${temp}/temp")
    test -e "${java}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 0
} > "${stdout}" 2>&1
echo "👍🏻 An empty Java file wasn't deleted"
