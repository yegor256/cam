#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

{
    set -x
    make clean "TARGET=${TARGET}"
    repo=yegor256/tojos
    log=$(make "TARGET=${TARGET}" "REPO=${repo}")
    echo "${log}"
    echo "${log}" | grep "Using one repo: yegor256/tojos"
    echo "${log}" | grep "No repo directories inside"
    echo "${log}" | grep "Cloned 1 repositories"
    echo "${log}" | grep "All 1 repositories checked"
    echo "${log}" | grep "All 1 repositories passed through jPeek"
    echo "${log}" | grep "All metrics calculated"
    echo "${log}" | grep "All metrics aggregated"
    echo "${log}" | grep "PDF report generated"
    echo "${log}" | grep "ZIP archive"
    echo "${log}" | grep "SUCCESS"
    echo "${log}" | grep -v "Failed to collect"
    test -d "${TARGET}"
    for f in start.txt hashes.csv report.pdf repositories.csv; do
        test -f "${TARGET}/${f}"
    done
    test "$(find "${TARGET}" -maxdepth 1 | wc -l | xargs)" = 11
    test -f "${TARGET}/data/${repo}/NCSS.csv"
    test -f "${TARGET}/data/${repo}/NHD.csv"
    test -f "${TARGET}/data/${repo}/SCOM-cvc.csv"
    test -f "${TARGET}/data/NCSS.csv"
    test -f "${TARGET}/data/NHD.csv"
    test -f "${TARGET}/data/SCOM-cvc.csv"
    test -d "${TARGET}/measurements/${repo}/src/main/java"
    test -d "${TARGET}/temp/jpeek/all/${repo}"
    test -d "${TARGET}/temp/jpeek/cvc/${repo}"
    test -f "${TARGET}/temp/reports/010-delete-non-java-files.sh.tex"
    test -f "${TARGET}/temp/pdf-report/report.tex"
    test -f "${TARGET}"/*.zip
    if grep "NaN" "${TARGET}/data/${repo}/NHD.csv"; then
        echo "NaN found in jpeek report"
        exit 1
    fi
    set +x
} > "${stdout}" 2>&1
echo "👍🏻 A full package processed correctly"
