#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

{
    mkdir -p "${TARGET}/something"
    "${LOCAL}/steps/zip.sh"
    test -e "${TARGET}"/*.zip
} > "${stdout}" 2>&1
echo "👍🏻 A zip archive generated correctly"

{
    mkdir -p "${TARGET}/something"
    zip=${TARGET}/cam-$(date +%Y-%m-%d).zip
    "${LOCAL}/steps/zip.sh"
    list=$(unzip -l "${zip}")
    echo "${list}" | grep "cam-sources/" > /dev/null
    echo "${list}" | grep --invert-match "cam-sources/.git" > /dev/null
} > "${stdout}" 2>&1
echo "👍🏻 A zip archive contains the CaM repository (without .git)"

{
    mkdir -p "${TARGET}/measurements/a/b/baam.m.cloc"
    mkdir -p "${TARGET}/temp/a/b/hello.txt"
    zip=${TARGET}/cam-$(date +%Y-%m-%d).zip
    "${LOCAL}/steps/zip.sh"
    list=$(unzip -l "${zip}")
    echo "${list}"
    test "$(echo "${list}" | grep -c "baam.m.cloc")" = '0'
    test "$(echo "${list}" | grep -c "hello.txt")" = '0'
} > "${stdout}" 2>&1
echo "👍🏻 A zip archive doesn't contain measurements/ and temp/"

{
    mkdir -p "${TARGET}/github/a/b/.git/baam/baam/boom/baam"
    touch "${TARGET}/github/a/b/hello"
    mkdir -p "${TARGET}/github/a/b/legal/.git/place"
    zip=${TARGET}/cam-$(date +%Y-%m-%d).zip
    "${LOCAL}/steps/zip.sh"
    list=$(unzip -l "${zip}")
    echo "${list}"
    echo "${list}" | grep "hello" > /dev/null
    test "$(echo "${list}" | grep -c "boom")" = '0'
    test "$(echo "${list}" | grep -c "place")" = '1'
} > "${stdout}" 2>&1
echo "👍🏻 A zip archive generated without .git directories inside"
