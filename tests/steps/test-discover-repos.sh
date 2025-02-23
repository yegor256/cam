#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

csv=${TARGET}/foo.csv
tex=${TARGET}/foo.tex

{
    rm -f "${csv}"
    msg=$("${LOCAL}/steps/discover-repos.rb" --dry --pause=0 --total=3 --page-size=1 --min-stars=100 --max-stars=1000 "--csv=${csv}"  "--tex=${tex}")
    echo "${msg}"
    echo "${msg}" | grep "Completed querying for year $(date +%Y). Found 3 repositories so far."
    echo "${msg}" | grep "Found 3 total repositories in GitHub"
    test -e "${csv}"
    test -s "${tex}"
    test "$(wc -l < "${csv}" | xargs)" = '4'
    test "$(head -1 "${csv}" | tr "," "\n" | wc -l | xargs)" = '9'
} > "${stdout}" 2>&1
echo "👍🏻 Small repositories discovery test is succeed"

{
    rm -f "${csv}"
    msg=$("${LOCAL}/steps/discover-repos.rb" --dry --pause=0 --total=35 --page-size=30 --min-stars=100 --max-stars=1000 "--csv=${csv}"  "--tex=${tex}")
    echo "${msg}"
    echo "${msg}" | grep "Found 60 total repositories in GitHub"
    echo "${msg}" | grep "We will use only the first 35 repositories"
    test -e "${csv}"
    test -s "${tex}"
    test "$(wc -l < "${csv}" | xargs)" = '36'
    test "$(head -1 "${csv}" | tr "," "\n" | wc -l | xargs)" = '9'
} > "${stdout}" 2>&1
echo "👍🏻 Medium repositories discovery test is succeed"
