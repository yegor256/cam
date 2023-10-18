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

flag=${TARGET}/temp/lint-done.txt

if [ -e "${flag}" ]; then
    echo "The quality of code has already been checked (run 'make clean' and then run 'make lint' again)"
    exit
fi

flake8 --max-line-length=140 "${LOCAL}/"

find "${LOCAL}" -type f -name '*.py' -print0 | xargs -0 -n1 pylint --enable-all-extensions \
    --disable=empty-comment \
    --disable=missing-module-docstring \
    --disable=invalid-name \
    --disable=too-many-try-statements \
    --disable=broad-exception-caught \
    --disable=magic-value-comparison \
    --disable=line-too-long \
    --disable=confusing-consecutive-elif \
    --disable=use-set-for-membership \
    --disable=duplicate-code

rubocop

find "${LOCAL}" -name '*.sh' -type f -print0 | xargs -0 -n1 shellcheck --shell=bash --severity=style

mkdir -p "$(dirname "${flag}")"
date +%s%N > "${flag}"
