#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    tmp=$(mktemp -d /tmp/XXXX)
    "${LOCAL}/metrics/authors.sh" "${tmp}" "${temp}/stdout"
    grep "NoGA 0 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Didn't fail in non-git directory"

{
    mkdir -p "${temp}/foo"
    cd "${temp}/foo"
    git init --quiet .
    git config user.email 'foo@example.com'
    git config user.name 'Foo'
    java="Foo long 'weird' name (--).java"
    echo "class Foo {}" > "${java}"
    git add "${java}"
    git config commit.gpgsign false
    git commit --quiet -am start
    "${LOCAL}/metrics/authors.sh" "${java}" stdout
    grep "NoGA 1 " stdout
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated authors"
