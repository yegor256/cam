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
    my_rvc=$(git log --pretty=format:"%h" "${java}" | wc -l)
    my_rvc=$((my_rvc+1))
    files=$(git ls-tree -r "$(git branch --show-current)" --name-only)
    all_rvcs=0

#  source: https://stackoverflow.com/questions/44440506/split-string-with-literal-n-in-a-for-loop
    while [[ $files ]]; do            # iterate as long as we have input
      if [[ $files = *$'\n'* ]]; then  # if there's a '\n' sequence later...
        first=${files%%$'\n'*}         #   put everything before it into 'first'
        rest=${files#*$'\n'}          #   and put everything after it in 'rest'
      else                          # if there's no '\n' later...
        first=${files}                 #   then put the whole rest of the string in 'first'
        rest=''                     #   and there is no 'rest'
      fi
      rvc=$(git log --pretty=format:"%h" "$first" | wc -l)
      rvc=$((rvc+1))
      all_rvcs=$((all_rvcs+rvc))
      files=$rest
    done
    rfvc=$(python3 -c "print(${my_rvc} / ${all_rvcs})")
else
    rfvc=0
fi

echo "RFVC ${rfvc} Relative File Volatility by Commits for file" > "${output}"
