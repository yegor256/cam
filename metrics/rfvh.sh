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
#set -o pipefail

java=$1
output=$(realpath "$2")

cd "$(dirname "${java}")"
base=$(basename "${java}")

# To check that file was added in commit any time
if git status > /dev/null 2>&1 && test -n "$(git log --oneline -- "${base}")"; then
    my_rvh=$(git log -L:"class\s:${java}" | grep -E "^[+-].*$" | grep -Ev "^\-\-\-\s\S+$" | grep -Evc "^\+\+\+\s\S+$")
    files=$(git ls-tree -r "$(git branch --show-current)" --name-only)
    all_rvhs=0

#  source: https://stackoverflow.com/questions/44440506/split-string-with-literal-n-in-a-for-loop
    while [[ $files ]]; do            # iterate as long as we have input
      if [[ $files = *$'\n'* ]]; then  # if there's a '\n' sequence later...
        first=${files%%$'\n'*}         #   put everything before it into 'first'
        rest=${files#*$'\n'}          #   and put everything after it in 'rest'
      else                          # if there's no '\n' later...
        first=${files}                 #   then put the whole rest of the string in 'first'
        rest=''                     #   and there is no 'rest'
      fi
      rvh=$(git log -L:"class\s:${first}" | grep -E "^[+-].*$" | grep -Ev "^\-\-\-\s\S+$" | grep -Evc "^\+\+\+\s\S+$")
      ((all_rvhs+=rvh))
      files=$rest
    done
    rfvh=$(python3 -c "print(${my_rvh} / ${all_rvhs})")
else
    rfvh=0
fi

echo "rfvh ${rfvh} Relative File Volatility by Hits for file" > "${output}"