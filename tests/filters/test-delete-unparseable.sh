#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    java="${temp}/Foo (; '''''\" привет.java"
    echo "this is not Java code at all" > "${java}"
    "${LOCAL}/filters/delete-unparseable.py" "${java}" "${temp}/deleted.txt"
    test ! -e "${java}"
    grep "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a broken syntax inside was deleted correctly"

{
    fixtures=$(realpath "$(dirname "$0")/../../fixtures/filters/unparseable")
    find "${fixtures}" -name '*.java' | while IFS= read -r f; do
        java="${temp}/$(basename "${f}")"
        cp "${f}" "${java}"
        "${LOCAL}/filters/delete-unparseable.py" "${java}" "${temp}/deleted.txt"
        test ! -e "${java}"
        grep "${java}" "${temp}/deleted.txt"
    done
} > "${stdout}" 2>&1
echo "👍🏻 All fixtures with broken syntax were deleted correctly"

{
    java=${temp}/Bar.java
    echo "class привет { --- }" > "${java}"
    "${LOCAL}/filters/delete-unparseable.py" "${java}" "${temp}/deleted.txt"
    test ! -e "${java}"
    grep "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 Another broken syntax inside was deleted correctly"

{
    "${LOCAL}/filters/delete-unparseable.py" "${temp}/file-is-absent.java" "${temp}/deleted.txt"
    grep -v "${temp}/file-is-absent.java" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 Absent file didn't fail the script"
