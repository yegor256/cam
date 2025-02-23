#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    metric_script_path="${LOCAL}/metrics/rfvc.sh"
    cd "${temp}"

    rm -rf ./*
    rm -rf .git

    git init --quiet .
    git config user.email 'foo@example.com'
    git config user.name 'Foo'
    git config commit.gpgsign false

    java_dir="./foo/dir/"
    java1="FooTest.java"
    java2="FooTest2.java"
    java3="FooTest3.java"

    mkdir -p "${java_dir}"
    cd ${java_dir}

    touch "${java1}"
    touch "stdout"

    printf "class Foo {}" > "${java1}"
    git add "${java1}"
    git commit --quiet -m "first commit"
    ${metric_script_path} "${java1}" "stdout"
    grep "RFVC 1" "stdout"

    printf "class Foo {}" > "${java2}"
    git add "${java2}"
    git commit --quiet -m "+second commit"

    ${metric_script_path} "${java1}" "stdout"
    grep "RFVC 0.5" "stdout"

    ${metric_script_path} "${java2}" "stdout"
    grep "RFVC 0.5" "stdout"


    printf "class Foo {}" > "${java3}"
    git add "${java3}"
    git commit --quiet -m "-third commit"

    ${metric_script_path} "${java1}" "stdout"
    grep "RFVC 0.33" "stdout"

    ${metric_script_path} "${java2}" "stdout"
    grep "RFVC 0.33" "stdout"

    ${metric_script_path} "${java3}" "stdout"
    grep "RFVC 0.33" "stdout"


    printf "class Foo2 {}" > "${java1}"
    git add "${java1}"
    git commit --quiet -m "forth commit"

    ${metric_script_path} "${java1}" "stdout"
    grep "RFVC 0.5" "stdout"

    ${metric_script_path} "${java2}" "stdout"
    grep "RFVC 0.25" "stdout"

    ${metric_script_path} "${java3}" "stdout"
    grep "RFVC 0.25" "stdout"


    printf "class Foo3 {}" > "${java1}"
    git add "${java1}"
    git commit --quiet -m "fifth commit"

    ${metric_script_path} "${java1}" "stdout"
    grep "RFVC 0.6" "stdout"


    ${metric_script_path} "${java2}" "stdout"
    grep "RFVC 0.2" "stdout"

    ${metric_script_path} "${java3}" "stdout"
    grep "RFVC 0.2" "stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated Relative File Volatility by Commits"
