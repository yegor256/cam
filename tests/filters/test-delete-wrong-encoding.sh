#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    javaTemp="${temp}/Foo1.java.temp"
    echo "interface Foo {}" > "${javaTemp}"
    java="${temp}/Foo1.java"
    echo "" > "${java}"
    iconv -f ASCII -t UTF-16 "${javaTemp}" > "${java}"
    "${LOCAL}/filters/delete-wrong-encoding.py" "${java}" "${temp}/deleted.txt"
    test ! -e "${java}"
    grep "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a UTF-16 encoding deleted correctly"

{
    javaTemp="${temp}/Foo2.java.temp"
    echo "interface Foo {}" > "${javaTemp}"
    java="${temp}/Foo2.java"
    echo "" > "${java}"
    iconv -f ASCII -t UTF-32 "${javaTemp}" > "${java}"
    "${LOCAL}/filters/delete-wrong-encoding.py" "${java}" "${temp}/deleted.txt"
    test ! -e "${java}"
    grep "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a UTF-32 encoding deleted correctly"

{
    java="${temp}/Foo3.java"
    echo "interface Foo {}" > "${java}"
    "${LOCAL}/filters/delete-wrong-encoding.py" "${java}" "${temp}/deleted.txt"
    test -e "${java}"
    grep -v "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a UTF-8 encoding was not deleted"

{
    if ! "${LOCAL}/filters/delete-wrong-encoding.py" > "${temp}/message"; then
        grep "Usage: python delete-wrong-encoding.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi
    if ! "${LOCAL}/filters/delete-wrong-encoding.py" "${java}" > "${temp}/message"; then
        grep "Usage: python delete-wrong-encoding.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi
    if ! "${LOCAL}/filters/delete-wrong-encoding.py" "${java}" "${temp}/stdout" "${temp}/stdout" > "${temp}/message"; then
        grep "Usage: python delete-wrong-encoding.py <path to the .java file> <output file with .java files>" "${temp}/message"
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Usage works correctly"
