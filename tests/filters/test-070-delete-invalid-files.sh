#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

list=${temp}/temp/filter-lists/invalid-files.txt

{
    java="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /Foo.java"
    mkdir -p "$(dirname "${java}")"
    echo "class Foo{} class Bar{}" > "${java}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/070-delete-invalid-files.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "1 files out of 1 with more than one Java class inside were deleted"
    test ! -e "${java}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 1
} > "${stdout}" 2>&1
echo "👍🏻 An invalid Java file was deleted"

{
    rm -f "${list}"
    mkdir -p "${temp}/empty"
    msg=$("${LOCAL}/filters/070-delete-invalid-files.sh" "${temp}/empty" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "There were no Java classes, nothing to delete"
} > "${stdout}" 2>&1
echo "👍🏻 A empty directory didn't fail the script"

{
    if ! "${LOCAL}/filters/delete-invalid-files.py" > "${temp}/message"; then
        grep "Usage: python delete-invalid-files.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi

    if ! "${LOCAL}/filters/delete-invalid-files.py" "${java}" > "${temp}/message"; then
        grep "Usage: python delete-invalid-files.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi

    if ! "${LOCAL}/filters/delete-invalid-files.py" "${java}" "${temp}/stdout" "${temp}/stdout" > "${temp}/message"; then
        grep "Usage: python delete-invalid-files.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Usage works correctly"
