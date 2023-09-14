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

for d in $(find "${TARGET}/github" -maxdepth 2 -mindepth 2 -type d -print); do
    repo=$(echo ${d} | sed "s|${TARGET}/github/||")
    if grep -Fxq "${repo}" ${TARGET}/repositories.csv; then
        echo "Directory ${d} is here and is needed (for ${repo})"
    else
        rm -rf "${d}"
        echo "Directory ${d} is obsolete and was deleted (for ${repo})"
    fi
done
for d in $(find "${TARGET}/github" -maxdepth 1 -mindepth 1 -type d -print); do
    if [ "$(ls ${d} | wc -l)" == '0' ]; then
        rm -rf "${d}"
        echo "Directory ${d} is empty and was deleted"
    fi
done
