#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    tmp=$(mktemp -d /tmp/XXXX)
    "${LOCAL}/metrics/aocih.sh" "${tmp}/Test.java" "${temp}/stdout"
    grep -q "AoCiH 0 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Didn't fail in non-git directory"

{
    mkdir -p "${temp}/foo"
    cd "${temp}/foo"
    git init --quiet .
    git config user.email 'foo@example.com'
    git config user.name 'Foo'
    git config commit.gpgsign false
    touch empty.file
    git add "empty.file"
    git commit --quiet -am "Initial commit"
    java="Test.java"
    echo "class Foo {}" > "${java}"
    git add "${java}"
    git commit --quiet -am "Second commit"
    git commit --amend --no-edit --date="$(date -d "+1 hour" --rfc-2822)"
    "${LOCAL}/metrics/aocih.sh" "${java}" stdout
    grep -q "AoCiH 1" stdout
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated AoCiH in the repository"
