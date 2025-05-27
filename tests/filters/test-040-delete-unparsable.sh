#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

temp=$1
stdout=$2

{
    list=${temp}/temp/filter-lists/unparsable-files.txt
    java="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /Foo.java"
    mkdir -p "$(dirname "${java}")"
    echo "--- not java syntax at all ---" > "${java}"
    another="$(dirname "${java}")/Bar.java"
    echo "class Bar {}" > "${another}"
    rm -f "${list}"
    msg=$("${LOCAL}/filters/040-delete-unparsable.sh" "${temp}" "${temp}/temp")
    echo "${msg}"
    echo "${msg}" | grep "1 files out of 2 with an unparsable Java syntax were deleted"
    test ! -e "${java}"
    test -e "${another}"
    test -e "${list}"
    test "$(wc -l < "${list}" | xargs)" = 1
} > "${stdout}" 2>&1
echo "👍🏻 An unparsable Java file was deleted"

{
    if ! "${LOCAL}/filters/delete-unparsable.py" > "${temp}/message"; then
        grep "Usage: python delete-unparsable.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi

    if ! "${LOCAL}/filters/delete-unparsable.py" "${java}" > "${temp}/message"; then
        grep "Usage: python delete-unparsable.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi

    if ! "${LOCAL}/filters/delete-unparsable.py" "${java}" "${temp}/stdout" "${temp}/stdout" > "${temp}/message"; then
        grep "Usage: python delete-unparsable.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Usage works correctly"
