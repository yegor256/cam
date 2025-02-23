#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    java="${temp}/Foo (x).java"
    echo "interface Foo {}" > "${java}"
    "${LOCAL}/filters/delete-non-classes.py" "${java}" "${temp}/deleted.txt"
    test ! -e "${java}"
    grep "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a small interface inside was deleted correctly"

{
    java="${temp}/foo/dir (with) _ long & and weird name /Foo.java"
    mkdir -p "$(dirname "${java}")"
    echo "/* hello */ package foo.bar.xxx; import java.io.File; public interface Foo { File bar(); }" > "${java}"
    "${LOCAL}/filters/delete-non-classes.py" "${java}" "${temp}/deleted.txt"
    test ! -e "${java}"
    grep "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a bigger interface inside was deleted correctly"

{
    java=${temp}/Bar.java
    echo "enum Bar {}" > "${java}"
    "${LOCAL}/filters/delete-non-classes.py" "${java}" "${temp}/deleted.txt"
    test ! -e "${java}"
    grep "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with a enum inside was deleted correctly"

{
    java=${temp}/Broken.java
    echo "broken syntax" > "${java}"
    "${LOCAL}/filters/delete-non-classes.py" "${java}" "${temp}/deleted.txt"
    test -e "${java}"
    grep -v "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A Java file with broken syntax was not deleted, this is correct"

{
    "${LOCAL}/filters/delete-non-classes.py" "${temp}/file-is-absent.java" "${temp}/deleted.txt"
    grep -v "${temp}/file-is-absent.java" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 Absent file didn't fail the script"

{
    java=${temp}/Good.java
    echo "class Good {}" > "${java}"
    "${LOCAL}/filters/delete-non-classes.py" "${java}" "${temp}/deleted.txt"
    test -e "${java}"
    grep -v "${java}" "${temp}/deleted.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A good Java file was not deleted, it's correct behavior"
