#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

uri=${temp}/foo!
git init --quiet --initial-branch=master "${uri}"
cd "${uri}"
git config user.email 'foo@example.com'
git config user.name 'Foo'
touch test.txt
git add .
git config commit.gpgsign false
git commit --quiet -am test

{
    echo -e "name\n${uri},master,4,5,5,6" > "${TARGET}/repositories.csv"
    rm -rf "${TARGET}/github"
    "${LOCAL}/steps/clone.sh"
    test -e "${TARGET}/github/files/foo!/test.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A repo cloned correctly"

{
    TARGET="${TARGET}/another/ж\"'  () привет /t"
    mkdir -p "${TARGET}"
    echo -e "name\n${uri}" > "${TARGET}/repositories.csv"
    rm -rf "${TARGET}/github"
    "${LOCAL}/steps/clone.sh"
    test -e "${TARGET}/github/files/foo!/test.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A repo cloned correctly into weird directory"
