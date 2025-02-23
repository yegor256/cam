#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

{
    javac -version
    mvn --version
    gradle --version
    java -jar "${JPEEK}" --help
} > "${stdout}" 2>&1
echo "👍🏻 jPeek dependencies are installed"

{
    repo="yegor256/jaxec"
    echo -e "name\n${repo}" > "${TARGET}/repositories.csv"
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/github/${repo}"
    cp -r "${LOCAL}/fixtures/jaxec"/* "${TARGET}/github/${repo}"
    msg=$("${LOCAL}/steps/jpeek-repo.sh" "${repo}" 1 1)
    test "$(echo "${msg}" | grep -c "0 classes, sum is 0")" = 0
    echo "${msg}" | grep "Analyzed ${repo} through jPeek"
    echo "${msg}" | grep ", 2 classes"
    mfile=${TARGET}/measurements/${repo}/src/main/java/com/yegor256/Jaxec.java.m.NHD
    test -e "${mfile}"
    value=$(cat "${mfile}")
    test ! "${value}" = '0'
    test ! "${value}" = 'NaN'
    test -e "${TARGET}/measurements/${repo}/src/main/java/com/yegor256/Jaxec.java.m.NHD-cvc"
    test ! -e "${TARGET}/measurements/${repo}/src/main/java/com/yegor256/Jaxec.java.m.NHD-cvc-cvc"
    test "$(grep -Ec 'Success.*Maven' "${TARGET}/temp/jpeek_success.log")" = '1'
} > "${stdout}" 2>&1
echo "👍🏻 A simple repo analyzed with jpeek correctly"

{
    repo="foo/bar"
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/temp/jpeek-logs/${repo}"
    msg=$("${LOCAL}/steps/jpeek-repo.sh" "${repo}" 1 1)
    echo "${msg}" | grep "Repo ${repo} already analyzed by jPeek"
} > "${stdout}" 2>&1
echo "👍🏻 A duplicate analysis didn't happen"
