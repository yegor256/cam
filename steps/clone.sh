#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
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

while IFS=',' read -r r tag; do
    if [ -e "${TARGET}/github/${r}" ]; then
        echo "${r}: Git repo is already here"
    else
        echo "${r}: trying to clone it..."
        if [ -z "${tag}" ]; then
            git clone --depth 1 "https://github.com/${r}" "${TARGET}/github/${r}"
        else
            git clone --depth 1 --branch="${tag}" "https://github.com/${r}" "${TARGET}/github/${r}"
        fi
        printf "${r},$(git --git-dir "${TARGET}/github/${r}/.git" rev-parse HEAD)\n" >> "${TARGET}/hashes.csv"
    fi
done < "${TARGET}/repositories.csv"
