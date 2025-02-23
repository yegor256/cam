#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

java=$1
output=$(realpath "$2")

cd "$(dirname "${java}")"

if git status > /dev/null 2>&1; then
    noca=$(git log --pretty=format:'%an%x09' "$(basename "${java}")" | sort | uniq | wc -l | xargs)
else
    noca=0
fi

echo "NoGA ${noca} Number of unique Git committers of a file" > "${output}"
