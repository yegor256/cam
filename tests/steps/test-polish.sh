#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

echo -e 'repo,branch\nfoo/bar,master,44,55' > "${TARGET}/repositories.csv"
rm -rf "${TARGET}/github"
mkdir -p "${TARGET}/github/foo/bar"
msg=$("${LOCAL}/steps/polish.sh")
test -e "${TARGET}/github/foo/bar"
{
    echo "${msg}"
    echo "${msg}" | grep "foo/bar is already here"
} > "${stdout}" 2>&1
echo "👍🏻 A correct directory was not deleted"

touch "${TARGET}/repositories.csv"
rm -rf "${TARGET}/github"
mkdir -p "${TARGET}/github/foo/bar"
msg=$("${LOCAL}/steps/polish.sh")
{
    echo "${msg}"
    echo "${msg}" | grep -v "foo/bar is obsolete and was deleted"
    echo "${msg}" | grep "All 1 repo directories"
} > "${stdout}" 2>&1
echo "👍🏻 An obsolete directory was deleted"

touch "${TARGET}/repositories.csv"
rm -rf "${TARGET}/github"
mkdir -p "${TARGET}/github"
msg=$("${LOCAL}/steps/polish.sh")
{
    echo "${msg}"
    echo "${msg}" | grep "No repo directories"
} > "${stdout}" 2>&1
echo "👍🏻 An empty directory was checked"

TARGET=${TARGET}/dir-is-absent
msg=$("${LOCAL}/steps/polish.sh")
{
    echo "${msg}"
    echo "${msg}" | grep "Nothing to polish, the directory is absent"
} > "${stdout}" 2>&1
echo "👍🏻 An absent directory passed filtering"
