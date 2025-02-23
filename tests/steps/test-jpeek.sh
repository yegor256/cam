#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

{
    repo="yegor256/jaxec"
    echo -e "name\n${repo}" > "${TARGET}/repositories.csv"
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/github/${repo}"
    cp -r "${LOCAL}/fixtures/jaxec"/* "${TARGET}/github/${repo}"
    msg=$("${LOCAL}/steps/jpeek.sh")
    echo "${msg}"
    echo "${msg}" | grep "Analyzed ${repo} through jPeek"
    mfile=${TARGET}/measurements/${repo}/src/main/java/com/yegor256/Jaxec.java.m.NHD
    value=$(cat "${mfile}")
    test ! "${value}" = '0'
    test ! "${value}" = 'NaN'
} > "${stdout}" 2>&1
echo "👍🏻 A simple repo analyzed with jpeek correctly"
