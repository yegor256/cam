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

start=$1
if [ -z "${start}" ]; then
    echo 'One argument is required'
    exit 1
fi

pfx=', in '
mks=$(echo "($(date +%s%N) - ${start}) / 1000" | bc)
if ((mks < 100)); then
    exit
elif ((mks < 1000)); then
    printf '%s%dμs' "${pfx}" "${mks}"
elif ((mks < 1000 * 1000)); then
    printf '%s%dms' "${pfx}" "$((mks / 1000))"
elif ((mks < 60 * 1000 * 1000)); then
    printf '%s%ds' "${pfx}" "$((mks / (1000 * 1000)))"
elif ((mks < 60 * 60 * 1000 * 1000)); then
    minutes=$((mks / (60 * 1000 * 1000)))
    seconds=$(((mks - minutes * 60 * 1000 * 1000) / (1000 * 1000)))
    printf '%s%dm%ds' "${pfx}" "${minutes}" "${seconds}"
else
    hours=$((mks / (60 * 60 * 1000 * 1000)))
    minutes=$(((mks - hours * 60 * 60 * 1000 * 1000) / (60 * 1000 * 1000)))
    printf '%s%dh%dm' "${pfx}" "${hours}" "${minutes}"
fi
