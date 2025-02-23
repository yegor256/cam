#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

java_file=$(realpath "$1")
output=$(realpath "$2")

age_in_hours=0
cd "$(dirname "${java_file}")"

if git status > /dev/null 2>&1; then
    repo_first_commit=$(git log --reverse --format=%at | head -n 1 || true)
    file_first_commit=$(git log --diff-filter=A --format=%at -- "$java_file" | tail -n 1 || true)
    if [[ -n "$repo_first_commit" && -n "$file_first_commit" ]]; then
        age_in_seconds=$((file_first_commit - repo_first_commit))
        age_in_hours=$((age_in_seconds / 3600))
    else
        echo "Warning: Unable to calculate commit age for $java_file" >&2
    fi
else
    echo "Error: Not a Git repository or unable to access it." >&2
fi

echo "AoCiH $age_in_hours Age of Class in Hours" > "$output"
