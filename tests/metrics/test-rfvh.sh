#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    metric_script_path="${LOCAL}/metrics/rfvh.sh"
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
    grep "RFVH 1" "stdout"

    printf "class Foo {}" > "${java2}"
    git add "${java2}"
    git commit --quiet -m "+second commit"
    ${metric_script_path} "${java1}" "stdout"
    grep "RFVH 0.5" "stdout"

    printf "class Foo {}" > "${java3}"
    git add "${java3}"
    git commit --quiet -m "-third commit"
    ${metric_script_path} "${java1}" "stdout"
    grep "RFVH 0.33" "stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated relative file volatility by hits"
