#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

java=$1
output=$(realpath "$2")

cd "$(dirname "${java}")"
base=$(basename "${java}")

# To check that file was added in commit any time
if git status > /dev/null 2>&1 && test -n "$(git log --oneline -- "${base}")"; then
    hoc=$(git log -L:"class\s:${java}" | grep -E "^[+-].*$" | grep -Ev "^\-\-\-\s\S+$" | grep -Evc "^\+\+\+\s\S+$")
else
    hoc=0
fi

echo "HoC ${hoc} Hits Of Code for file" > "${output}"
