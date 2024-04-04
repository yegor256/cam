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

repo=$1
pos=$2
total=$3
metrics=$4

start=$(date +%s%N)

dir=${TARGET}/measurements/${repo}
ddir=${TARGET}/data/${repo}
if [ -e "${ddir}" ]; then
    declare -i found=0
    declare -i missing=0
    for m in ${metrics}; do
        if [ -e "${ddir}/${m}.csv" ]; then
            found=$((found+1))
        else
            missing=$((missing+1))
        fi
    done
    if [ "${missing}" = 0 ]; then
        echo "All ${found} metrics in ${repo} already aggregated (${pos}/${total}): ${ddir}"
        exit
    fi
    echo "Not all $((found+missing)) metrics aggregated in ${repo} (${pos}/${total}), ${missing} missing: ${ddir}"
fi

if [ ! -e "${dir}" ]; then
    echo "Nothing to aggregate in ${repo} (${pos}/${total}), no measurements in ${ddir}"
    exit
fi

mfiles=${TARGET}/temp/mfiles/${repo}.txt
mkdir -p "$(dirname "${mfiles}")"
find "${dir}" -type f -name '*.m' > "${mfiles}"

sum=0
declare -i files=0
while IFS= read -r m; do
    slice=${TARGET}/temp/mfiles-slice.txt
    find "$(dirname "${m}")" -name "$(basename "${m}").*" -type f -print > "${slice}"
    while IFS= read -r v; do
        java=$(echo "${v}" | sed "s|${dir}||" | sed "s|\.m\..*$||")
        metric=${v//${dir}${java}\.m\./}
        csv=${ddir}/${metric}.csv
        mkdir -p "$(dirname "${csv}")"
        if [ ! -e "${csv}" ]; then
            printf 'java_file,%s\n' "${metric}" > "${csv}"
        fi
        printf '%s,%s\n' "$(echo "${java}" | "${LOCAL}/help/to-csv.sh")" "$(cat "${v}")" >> "${csv}"
    done < "${slice}"
    csv=${ddir}/all.csv
    mkdir -p "$(dirname "${csv}")"
    if [ ! -e "${csv}" ]; then
        printf 'java_file' > "${csv}"
        for a in ${metrics}; do
            printf ",%s" "${a}" >> "${csv}"
        done
        printf '\n' >> "${csv}"
    fi
    java=$(echo "${m}" | sed "s|${dir}||" | sed "s|\.m$||")
    printf '%s' "$(echo "${java}" | "${LOCAL}/help/to-csv.sh")" >> "${csv}"
    for a in ${metrics}; do
        if [ -e "${m}.${a}" ]; then
            value=$("${LOCAL}/help/float.sh" < "${m}.${a}")
            printf ",%s" "${value}" >> "${csv}"
            if [ ! "${value}" = "NaN" ]; then
                sum=$(echo "${sum} + ${value}" | bc | "${LOCAL}/help/float.sh")
            fi
        else
            printf ',-' >> "${csv}"
        fi
    done
    printf '\n' >> "${csv}"
    files=$((files+1))
done < "${mfiles}"

echo "${repo} (${pos}/${total}) aggregated (.m files=${files}, sum=${sum})$("${LOCAL}/help/tdiff.sh" "${start}")"
