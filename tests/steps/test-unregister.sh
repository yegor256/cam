#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

{
    echo -e 'repo,branch\nfoo/bar,master,44,99\nboom/boom,master\n' > "${TARGET}/repositories.csv"
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/github/boom/boom"
    msg=$("${LOCAL}/steps/unregister.sh")
    echo "${msg}"
    cat "${TARGET}/temp/repositories-before-unregister.txt"
    cat "${TARGET}/repositories.csv"
    grep "boom/boom" "${TARGET}/repositories.csv"
    echo "${msg}" | grep "All 2 repositories checked"
    echo "${msg}" | grep "The clone of foo/bar is absent, unregistered"
    test "$(wc -l < "${TARGET}/repositories.csv" | xargs)" = '2'
} > "${stdout}" 2>&1
echo "👍🏻 A broken repo clone was unregistered"
