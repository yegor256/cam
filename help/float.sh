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

#!/bin/bash
is_float() {
    local re="^-?[0-9]*\.?[0-9]+$"
    [[ $1 =~ $re ]]
}

set -e
set -o pipefail

num=$(cat)

if [[ -z "${num}" || "${num}" =~ ^[[:space:]]+$ ]]; then
    echo "0.000"  
    exit
fi

if [ "${num}" == 'NaN' ]; then
    printf '%s' "${num}"
    exit
fi
if ! is_float "$num"; then
    echo "0.000"
    exit 1
fi

num_truncated=$(echo "$num * 1000 / 1" | bc)
LC_NUMERIC=C printf '%.3f' "$(echo "$num_truncated / 1000" | bc -l)" 2>/dev/null || echo "0.000"
