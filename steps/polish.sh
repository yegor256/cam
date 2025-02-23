#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

dir=${TARGET}/github
if [ ! -e "${dir}" ]; then
    echo "Nothing to polish, the directory is absent: ${dir}"
    exit
fi

rlist=${TARGET}/temp/repos-to-polish.txt
mkdir -p "$(dirname "${rlist}")"
echo "Wait a bit, searching for repos in '${dir}'..."
find "${dir}" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'realpath --relative-to="${1}" "$2"' _ "${dir}" {} \; > "${rlist}"

if [ -s "${rlist}" ]; then
    declare -i rtotal=0
    while IFS= read -r repo; do
        if grep "${repo}," "${TARGET}/repositories.csv"; then
            echo "Directory of ${repo} is already here"
        else
            rm -rf "${dir:?}/${repo}"
            echo "Directory of ${repo} is obsolete and was deleted"
        fi
        rtotal=$((rtotal+1))
    done < "${rlist}"
    echo "All ${rtotal} repo directories inside ${dir} were checked"
else
    echo "No repo directories inside ${dir}"
    exit
fi

olist=${TARGET}/temp/orgs-to-polish.txt
mkdir -p "$(dirname "${olist}")"
echo "Wait a bit, searching for orgs in '${dir}'..."

find "${dir}" -maxdepth 1 -mindepth 1 -type d -exec bash -c 'realpath --relative-to="${1}" "$2"' _ "${dir}" {} \; > "${olist}"

if [ -s "${olist}" ]; then
    declare -i ototal=0
    while IFS= read -r org; do
        if [ "$(find "${dir}/${org}" -type d | wc -l | xargs)" == '0' ]; then
            rm -rf "${dir:?}/${org}"
            echo "Organization ${org} is empty and was deleted"
        fi
        ototal=$((ototal+1))
    done < "${olist}"
    echo "All ${ototal} org directories inside ${dir} were checked"
else
    echo "No org directories inside ${dir}"
    exit
fi
