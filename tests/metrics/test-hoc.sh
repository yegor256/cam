#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    hoc_script_path="${LOCAL}/metrics/hoc.sh"
    cd "${temp}"

    rm -rf ./*
    rm -rf .git

    git init --quiet .
    git config user.email 'foo@example.com'
    git config user.name 'Foo'
    git config commit.gpgsign false

    java_dir="./foo/dir/"
    java="FooTest.java"

    mkdir -p "${java_dir}"
    cd ${java_dir}

    touch "${java}"
    touch "stdout"

    printf "class Foo {}" > "${java}"
    git add "${java}"
    git commit --quiet -m "first commit"
    ${hoc_script_path} "${java}" "stdout"
    grep "HoC 1" "stdout"

    printf "class Foo {\n\tint x;\n\tbool y;\n}\n" > "${java}"
    git add "${java}"
    git commit --quiet -m "+second commit"
    ${hoc_script_path} "${java}" "stdout"
    grep "HoC 6" "stdout"

    printf "class Foo {\n\tbool z;\n}\n" > "${java}"
    git add "${java}"
    git commit --quiet -m "-third commit"
    ${hoc_script_path} "${java}" "stdout"
    grep "HoC 9" "stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated hits of code"
