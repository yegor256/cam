#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

{
    repo="foo/bar test, ; "
    dir="${TARGET}/measurements/${repo}/a, ; -"
    mkdir -p "${dir}"
    m="Foo,- ;Bar.java.m"
    touch "${dir}/${m}"
    echo ".75" > "${dir}/${m}.nhd"
    echo "42" > "${dir}/${m}.loc"
    msg=$("${LOCAL}/steps/aggregate-repo.sh" "${repo}" 1 1 'loc nhd')
    test "$(echo "${msg}" | grep -c "sum=0")" == 0
    test "$(echo "${msg}" | grep -c "files=0")" == 0
    test -e "${TARGET}/data/${repo}/all.csv"
    grep "/a\\\\, ; -/Foo\\\\,- ;Bar.java,42.000,0.750" "${TARGET}/data/${repo}/all.csv"
    grep "java_file,loc,nhd" "${TARGET}/data/${repo}/all.csv"
    test -e "${TARGET}/data/${repo}/loc.csv"
    grep "java_file,loc" "${TARGET}/data/${repo}/loc.csv"
    grep "/a\\\\, ; -/Foo\\\\,- ;Bar.java,42" "${TARGET}/data/${repo}/loc.csv"
    test -e "${TARGET}/data/${repo}/nhd.csv"
    grep ",42" "${TARGET}/data/${repo}/loc.csv"
} > "${stdout}" 2>&1
echo "👍🏻 A repo aggregated correctly"

{
    repo="dog/cat"
    dir="${TARGET}/data/${repo}"
    mkdir -p "${dir}"
    touch "${dir}/loc.csv"
    msg=$("${LOCAL}/steps/aggregate-repo.sh" "${repo}" 1 1 'loc nhd')
    echo "${msg}" | grep "Not all 2 metrics aggregated"
} > "${stdout}" 2>&1
echo "👍🏻 A partially aggregated repo processed correctly"
