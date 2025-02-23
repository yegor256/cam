#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

repo=$1
tag=$2
pos=$3
total=$4

start=$(date +%s%N)

if [[ "${repo}" =~ '!' ]]; then
    uri=file://${repo}
    repo=files/$(basename "${repo}")
else
    uri=https://github.com/${repo}
fi

dir=${TARGET}/github/${repo}

if [ -e "${dir}" ]; then
    echo "The repo directory #${pos}/${total} is already here: ${dir} ($(du -sh "${dir}" | cut -f1 | xargs))"
    exit
fi

declare -a args=('--quiet')
if [ ! "${tag}" = '.' ]; then
    args+=("--branch=${tag}")
fi

echo "${repo} (${pos}/${total}): trying to clone it..."
declare -i re=0
until timeout 1h git clone "${args[@]}" "${uri}" "${dir}"; do
    if [ "${re}" -gt 5 ]; then
        echo "Too many failures (${re}) for ${repo}"
        exit 1
    fi
    re=$((re+1))
    rm -rf "${dir}"
    echo "Retry #${re} for ${repo}..."
    sleep "${re}"
done

hashes=${TARGET}/hashes.csv
if [ ! -e "${hashes}" ]; then
    printf "repo,hash\n" > "${hashes}"
fi
printf "%s,%s\n" "$(echo "${repo}" | "${LOCAL}/help/to-csv.sh")" "$(git --git-dir "${dir}/.git" rev-parse HEAD)" >> "${hashes}"

echo "${repo} cloned (${pos}/${total}), $(du -sh "${dir}" | cut -f1 | xargs)$("${LOCAL}/help/tdiff.sh" "${start}")"
