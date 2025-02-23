#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

csv=${TARGET}/repositories.csv

{
    rm -f "${csv}"
    TOTAL=3 "${LOCAL}/steps/discover.sh"
    test -e "${csv}"
    test -s "${TARGET}/temp/repo-details.tex"
    test "$(wc -l < "${csv}" | xargs)" = '4'
} > "${stdout}" 2>&1
echo "👍🏻 A few repositories discovered correctly"

{
    rm -f "${csv}"
    REPO=yegor256/jaxec "${LOCAL}/steps/discover.sh"
    test -e "${csv}"
    test -s "${TARGET}/temp/repo-details.tex"
    test "$(wc -l < "${csv}" | xargs)" = '2'
} > "${stdout}" 2>&1
echo "👍🏻 A single repository discovered correctly"
