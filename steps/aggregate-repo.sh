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

repo=$1
pos=$2
total=$3

ddir=$(echo "${repo}" | sed "s|${TARGET}/measurements|${TARGET}/data|")
if [ -e "${ddir}" ]; then
    echo "${repo} already aggregated (${pos}/${total}): ${ddir}"
    exit
fi
find "${repo}" -name '*.m' | while IFS= read -r m; do
    for v in $(ls ${m}.*); do
        java=$(echo "${v}" | sed "s|${repo}||" | sed "s|\.m\..*$||")
        metric=$(echo "${v}" | sed "s|${repo}${java}.m.||")
        csv="${ddir}/${metric}.csv"
        mkdir -p $(dirname "${csv}")
        echo "${java},$(cat "${v}")" >> "${csv}"
    done
    csv="${ddir}/all.csv"
    mkdir -p "$(dirname "${csv}")"
    java=$(echo "${m}" | sed "s|${repo}||" | sed "s|\.m$||")
    printf "${java}" >> "${csv}"
    for a in ${all}; do
        if [ -e "${m}.${a}" ]; then
            printf ",$(cat "${m}.${a}")" >> "${csv}"
        else
            printf ',-' >> "${csv}"
        fi
    done
    printf "\n" >> "${csv}"
done
echo "${repo} aggregated (${pos}/${total})"
