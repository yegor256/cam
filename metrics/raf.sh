#!/usr/bin/env bash

set -e
set -o pipefail

file=$1
output=$(realpath "$2")

# To make sure that python is installed
python --version > /dev/null

# To check that file was added in commit any time


if git status > /dev/null 2>&1 && test -n "$(git log --oneline -- "${file}")"; then
    file_creation=$(git log --pretty=format:"%ci" --date=default -- "${file}" | tail -n 1)
    repo_creation=$(git log --reverse --format="format:%ci" | sed -n 1p)
    current_time=$(date "+%Y-%m-%d %H:%M:%S %z")
    file_creation_timestamp=$(date -d "$file_creation" +%s)
    repo_creation_timestamp=$(date -d "$repo_creation" +%s)
    current_time_timestamp=$(date -d "$current_time" +%s)
    from_file_creation=$((current_time_timestamp - file_creation_timestamp))
    from_repo_creation=$((current_time_timestamp - repo_creation_timestamp))
    raf=$(echo 'import sys; print(1 - float(sys.argv[1])/float(sys.argv[2]) if float(sys.argv[2]) != 0 else 1.0)' | python - $((from_file_creation)) $((from_repo_creation)))
else
    raf=0
fi

echo "raf ${raf} Relative Age of File (To repository existence)" > "${output}"