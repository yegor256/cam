#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2023 Yegor Bugayenko
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

dir=${TARGET}/github

declare -i cnt=0
find "${dir}" -maxdepth 2 -mindepth 2 -type d -exec realpath --relative-to="${dir}" {} \; | while read -r repo; do
    cnt=$((cnt+1))
    if grep -Fxq "${repo}" "${TARGET}/repositories.csv"; then
        echo "Directory of ${repo} is already here"
    else
        rm -rf "${dir:?}/${repo}"
        echo "Directory of ${repo} is obsolete and was deleted"
    fi
done
echo "All ${cnt} repo directories inside ${dir} look good"

cnt=0
find "${dir}" -maxdepth 1 -mindepth 1 -type d -exec realpath --relative-to="${dir}" {} \; | while read -r org; do
    cnt=$((cnt+1))
    if [ "$(find "${dir}/${org}" | wc -l | xargs)" == '0' ]; then
        rm -rf "${dir:?}/${org}"
        echo "Organization ${org} is empty and was deleted"
    fi
done
echo "All ${cnt} user directories inside ${dir} look good"

