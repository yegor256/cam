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

temp=$2

if [ ! -e "${TARGET}/github" ]; then exit; fi

list=${temp}/git-to-move.txt
find "${TARGET}/github" -maxdepth 2 -mindepth 2 -type d -exec realpath --relative-to="${TARGET}/github" {} \; > "${list}"

gits=${temp}/gits
mkdir -p "${gits}"

if [ -s "${list}" ]; then
    while IFS= read -r repo; do
        src=${TARGET}/github/${repo}/.git
        if [ ! -e "${src}" ]; then continue; fi
        mkdir -p "$(dirname "${gits}/${repo}")"
        mv "${src}" "${gits}/${repo}"
    done < "${list}"
fi
