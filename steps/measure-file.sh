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

java=$1
javam=$2
pos=$3
total=$4

start=$(echo "$(date +%s%N) / 1000000" | bc)

mkdir -p "$(dirname "${javam}")"
metrics=$(find "${LOCAL}/metrics/" -type f -exec basename {} \;)
echo "${metrics}" | while read -r m; do
    # @todo #74 This metric doesn't work, because when we run it,
    #  the directory already doesn't have the ".git" folder --- it was filtered out
    #  by one of the filters in the "filters/" directory. Probably, we should avoid shallow clones
    #  and then get an opportunity to have more Git-based metrics.
    if [ "${m}" = "authors.sh" ]; then continue; fi
    if timeout 30m "metrics/${m}" "${java}" "${javam}"; then
        while read -r t; do
            IFS=' ' read -r -ra M <<< "${t}"
            echo "${M[1]}" > "${javam}.${M[0]}"
        done < "${javam}"
    else
        echo "Failed to collect ${m} for ${java}"
    fi
done

end=$(echo "$(date +%s%N) / 1000000" | bc)

echo "$(echo "${metrics}" | wc -w | xargs) scripts \
collected $(find "${javam}".* -type f | wc -l | xargs) metrics \
for $(basename "${java}") (${pos}/${total}) in $(( end > start ? end - start : 0 ))ms"
