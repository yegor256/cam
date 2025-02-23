#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2
file_name="file -p (test ) \n\?.k"
repo_name="comp_.lex\$repo[info]>"

{
    echo "${TARGET}"
    rm -rf "${TARGET}/data"
    rm -rf "${TARGET}/measurements"
    rm -rf "${TARGET}/summary"
    rm -rf "${TARGET}/temp"
    dir1="${TARGET}/measurements/${repo_name}1"
    mkdir -p "${dir1}"
    "${LOCAL}/steps/summarize.sh"
    test -z "$(ls -A "${TARGET}/data/summary")"
} > "${stdout}" 2>&1
echo "👍🏻 Summarization step handled empty repository correctly"

{
    rm -rf "${TARGET}/data"
    rm -rf "${TARGET}/measurements"
    rm -rf "${TARGET}/summary"
    rm -rf "${TARGET}/temp"
    dir1="${TARGET}/measurements/${repo_name}1"
    mkdir -p "${TARGET}/temp"
    touch "${TARGET}/temp/repos-to-aggregate.txt"
    echo "${repo_name}1" >> "${TARGET}/temp/repos-to-aggregate.txt"
    mkdir -p "${dir1}"
    echo "50" > "${dir1}/${file_name}1.m.LOC"
    echo "100" > "${dir1}/${file_name}2.m.LOC"
    echo "10" > "${dir1}/${file_name}1.m.CYC"
    echo "20" > "${dir1}/${file_name}2.m.CYC"
    "${LOCAL}/steps/summarize.sh"
    test -e "${TARGET}/data/summary/LOC.csv"
    test -e "${TARGET}/data/summary/CYC.csv"
    grep -F "${repo_name}1,2,150" < "${TARGET}/data/summary/LOC.csv"
    grep -F "${repo_name}1,2,30" < "${TARGET}/data/summary/CYC.csv"
} > "${stdout}" 2>&1
echo "👍🏻 Summarization step handled multiple metrics correctly"

{
    rm -rf "${TARGET}/data"
    rm -rf "${TARGET}/measurements"
    rm -rf "${TARGET}/summary"
    rm -rf "${TARGET}/temp"
    dir1="${TARGET}/measurements/${repo_name}1"
    mkdir -p "${TARGET}/temp"
    touch "${TARGET}/temp/repos-to-aggregate.txt"
    echo "${repo_name}1" >> "${TARGET}/temp/repos-to-aggregate.txt"
    echo "${repo_name}2" >> "${TARGET}/temp/repos-to-aggregate.txt"
    mkdir -p "${dir1}"
    echo "50" > "${dir1}/${file_name}1.m.LOC"
    echo "100" > "${dir1}/${file_name}2.m.LOC"
    echo "10" > "${dir1}/${file_name}1.m.CYC"
    dir2="${TARGET}/measurements/${repo_name}2"
    mkdir -p "${dir2}"
    echo "25" > "${dir2}/${file_name}1.m.LOC"
    "${LOCAL}/steps/summarize.sh"
    test -e "${TARGET}/data/summary/LOC.csv"
    grep -F "${repo_name}1,2,150" < "${TARGET}/data/summary/LOC.csv"
    grep -F "${repo_name}2,1,25" < "${TARGET}/data/summary/LOC.csv"
    test -e "${TARGET}/data/summary/CYC.csv"
    grep -F "${repo_name}1,1,10" < "${TARGET}/data/summary/CYC.csv"
    if grep "${repo_name}2" < "${TARGET}/data/summary/CYC.csv"; then
        exit 1
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Summarization step handled mixed metrics across repositories correctly"
