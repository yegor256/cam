#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e
set -o pipefail

java_file=$(realpath $1)
output=$(realpath "$2")

age_in_hours=0

cd "$(dirname "${java_file}")"

if git status > /dev/null 2>&1; then
    repo_first_commit=$(git log --reverse --format=%at | head -1)
    file_first_commit=$(git log --diff-filter=A --format=%at -- "$java_file" | tail -1)
    if [[ -z "$file_first_commit" ]]; then
        age_in_hours=0
    else
        age_in_seconds=$((file_first_commit - repo_first_commit))
        age_in_hours=$((age_in_seconds / 3600))
    fi
fi

echo "AoCiH $age_in_hours Age of Class in Hours" > "$output"
