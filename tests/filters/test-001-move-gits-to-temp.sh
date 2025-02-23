#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

temp=$1
stdout=$2

{
    rm -rf "${TARGET}/github"
    msg=$("${LOCAL}/filters/001-move-gits-to-temp.sh" "${temp}" "${temp}")
    echo "${msg}"
} > "${stdout}" 2>&1
echo "👍🏻 An empty directory didn't crash it"

{
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/github/foo/bar"
    msg=$("${LOCAL}/filters/001-move-gits-to-temp.sh" "${temp}" "${temp}")
    echo "${msg}"
} > "${stdout}" 2>&1
echo "👍🏻 An empty repo directory didn't crash it"

{
    repo=foo/bar
    mkdir -p "${TARGET}/github/${repo}/.git/test.txt"
    msg=$("${LOCAL}/filters/001-move-gits-to-temp.sh" "${temp}" "${temp}")
    echo "${msg}"
    ls -al "${TARGET}/github/${repo}"
    test ! -e "${TARGET}/github/${repo}/.git"
    ls -al "${temp}/gits/${repo}"
    test -e "${temp}/gits/${repo}/test.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A git repository was moved to temp dir"

{
    first=foo/first
    second=foo/second
    mkdir -p "${TARGET}/github/${first}/.git/test.txt"
    mkdir -p "${TARGET}/github/${second}/.git/test.txt"
    msg=$("${LOCAL}/filters/001-move-gits-to-temp.sh" "${temp}" "${temp}")
    echo "${msg}"
    ls -al "${TARGET}/github/${first}"
    test ! -e "${TARGET}/github/${first}/.git"
    ls -al "${temp}/gits/${second}"
    test -e "${temp}/gits/${second}/test.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A pair of git repositories were moved to temp dir"
