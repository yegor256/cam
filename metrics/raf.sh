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
    file_creation=$(git log --pretty=format:"%ci" --date=default -- "${base}" | tail -n 1)
    repo_creation=$(git log --reverse --format="format:%ci" | sed -n 1p)
    current_time=$(date "+%Y-%m-%d %H:%M:%S %z")
    file_creation_timestamp=$(date -d "$file_creation" +%s)
    repo_creation_timestamp=$(date -d "$repo_creation" +%s)
    current_time_timestamp=$(date -d "$current_time" +%s)
    from_file_creation=$((current_time_timestamp - file_creation_timestamp))
    from_repo_creation=$((current_time_timestamp - repo_creation_timestamp))
    raf=$(echo 'import sys; print(round(float(sys.argv[1])/float(sys.argv[2]), 1) if float(sys.argv[2]) != 0 else 1.0)' | python3 - $((from_file_creation)) $((from_repo_creation)))
else
    raf=0
fi

echo "RAF ${raf} Relative Age of File (in the entire timeframe of repository existence), \
    where 0.0 means the file was added in the first commit and 1.0 means that \
    the file was added in the last commit" > "${output}"
