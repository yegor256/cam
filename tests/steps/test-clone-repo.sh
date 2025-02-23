#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

uri=${temp}/foo!
git init --quiet "${uri}"
cd "${uri}"
git config user.email 'foo@example.com'
git config user.name 'Foo'
touch test.txt
git add .
git config commit.gpgsign false
git commit --quiet -am test

{
    rm -rf "${TARGET}/github"
    "${LOCAL}/steps/clone-repo.sh" "${uri}" . 1 1
    test -e "${TARGET}/github/files/foo!/test.txt"
    echo "👍🏻 A repo cloned correctly"
    "${LOCAL}/steps/clone-repo.sh" "${uri}" . 1 1
} > "${stdout}" 2>&1
echo "👍🏻 A re-clone worked correctly"
