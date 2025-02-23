#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

list=${temp}/temp/filter-lists/non-class-files.txt

{
    java="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /Foo.java"
    mkdir -p "$(dirname "${java}")"
    echo "interface Foo {}" > "${java}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/060-delete-non-classes.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "1 files out of 1 with interfaces or enums (instead of classes) inside were deleted"
    test ! -e "${java}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 1
} > "${stdout}" 2>&1
echo "👍🏻 A file with a Java interface was deleted"

{
    if ! "${LOCAL}/filters/delete-non-classes.py" > "${temp}/message"; then
        grep "Usage: python delete-non-classes.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi

    if ! "${LOCAL}/filters/delete-non-classes.py" "${java}" > "${temp}/message"; then
        grep "Usage: python delete-non-classes.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi

    if ! "${LOCAL}/filters/delete-non-classes.py" "${java}" "${temp}/stdout" "${temp}/stdout" > "${temp}/message"; then
        grep "Usage: python delete-non-classes.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Usage works correctly"
