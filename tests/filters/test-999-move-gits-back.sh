#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

temp=$1
stdout=$2

{
    rm -rf "${temp}/gits"
    msg=$("${LOCAL}/filters/999-move-gits-back.sh" "${temp}" "${temp}")
    echo "${msg}"
} > "${stdout}" 2>&1
echo "👍🏻 An absent directory didn't crash it"

{
    rm -rf "${temp}/gits"
    mkdir -p "${temp}/gits"
    msg=$("${LOCAL}/filters/999-move-gits-back.sh" "${temp}" "${temp}")
    echo "${msg}"
} > "${stdout}" 2>&1
echo "👍🏻 An empty directory didn't crash it"

{
    rm -rf "${temp}/gits"
    mkdir -p "${temp}/gits/foo/bar"
    msg=$("${LOCAL}/filters/999-move-gits-back.sh" "${temp}" "${temp}")
    echo "${msg}"
} > "${stdout}" 2>&1
echo "👍🏻 An empty repo directory didn't crash it"

{
    repo=foo/bar
    mkdir -p "${TARGET}/github/${repo}"
    mkdir -p "${temp}/gits/${repo}/.git/foo.txt"
    msg=$("${LOCAL}/filters/999-move-gits-back.sh" "${temp}" "${temp}")
    echo "${msg}"
    ls -al "${TARGET}/github/${repo}"
    test -e "${TARGET}/github/${repo}/.git"
    ls -al "${temp}/gits"
    test ! -e "${temp}/gits/${repo}/test.txt"
} > "${stdout}" 2>&1
echo "👍🏻 A git repository was moved back"
