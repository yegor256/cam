#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

{
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/github/a/b"
    msg=$("${LOCAL}/steps/filter.sh")
    echo "${msg}"
} > "${stdout}" 2>&1
echo "👍🏻 A simple filtering ran smoothly"

{
    rm -rf "${TARGET}/github"
    rm -rf "${TARGET}/temp/reports"
    rm -rf "${TARGET}/temp/filter-lists"
    dir=${TARGET}/github
    mkdir -p "${dir}"
    mkdir -p "${dir}/a/b/.git"
    touch "${dir}/a/b/.git/boom"
    echo "nothing" > "${dir}/package-info.java"
    echo "nothing" > "${dir}/module-info.java"
    echo "nothing" > "${dir}/FooTest.java"
    echo "class X {} class Y {} class Z {}" > "${dir}/XYZ.java"
    printf 'class Boom { String x = "a%.0s"; }' {1..5000} > "${dir}/Boom.java"
    javaTemp="${dir}/WrongEncoding.java.temp"
    echo 'class Foo { String x = "привет"; }' > "${javaTemp}"
    iconv -f UTF-8 -t UTF-16 "${javaTemp}" > "${dir}/WrongEncoding.java"
    ln -s "${dir}/FooTest.java" "${dir}/link.java"
    class="${dir}/a/b/foo - '(weird)'/привет/Foo.java"
        mkdir -p "$(dirname "${class}")"
        echo "class Foo {}" > "${class}"
        echo "nothing" > "${class}.bin"
    interface="${dir}/foo/-- \";'/тук тук/Boom.java"
        mkdir -p "$(dirname "${interface}")"
        echo "interface Boom {}" > "${interface}"
    broken="${dir}/''foo/;;'\"/вот/так/Broken-файл.java"
        mkdir -p "$(dirname "${broken}")"
        echo "broken code" > "${broken}"
    msg=$("${LOCAL}/steps/filter.sh")
    echo "${msg}"
    if [ ! "$(echo "${msg}" | grep -c "didn't touch any files")" -eq 0 ]; then
        echo "One of the filters didn't do anything, which is wrong."
        echo "This test is designed to trigger all available filters, without exception."
        echo "If you add a new filter to the filters/ directory, make sure it is triggered here too."
        exit 1
    fi
    test ! -e "${broken}"
    test ! -e "${interface}"
} > "${stdout}" 2>&1
echo "👍🏻 A more complex filtering ran smoothly"
