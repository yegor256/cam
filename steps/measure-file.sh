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

java=$1
javam=$2
pos=$3
total=$4

start=$(date +%s%N)

mkdir -p "$(dirname "${javam}")"
touch "${javam}"
metrics=$(find "${LOCAL}/metrics/" -type f -exec test -x {} \; -exec basename {} \;)
echo "${metrics}" | {
    sum=0
    while IFS= read -r m; do
        if timeout 30m "metrics/${m}" "${java}" "${javam}"; then
            while IFS= read -r t; do
                IFS=' ' read -r -ra M <<< "${t}"
                value=$(echo "${M[1]}" | "${LOCAL}/help/float.sh")
                echo "${value}" > "${javam}.${M[0]}"
                if [ ! "${value}" = "NaN" ]; then
                    sum=$(echo "${sum} + ${value}" | bc | "${LOCAL}/help/float.sh")
                fi
            done < "${javam}"
        else
            echo "Failed to collect ${m} for ${java}"
        fi
    done
    echo "$(echo "${metrics}" | wc -w | xargs) scripts \
collected $(find "$(dirname "${javam}")" -type f -name "$(basename "${javam}").*" | wc -l | xargs) metrics (sum=${sum}) \
for $(basename "${java}") (${pos}/${total})$("${LOCAL}/help/tdiff.sh" "${start}")"
}
