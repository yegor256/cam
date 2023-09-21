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
set -o pipefail

start=$(date +%s)

echo "Searching for all .java files in ${TARGET}/github (may take some time, stay calm...)"

javas=$(find "${TARGET}/github" -name '*.java' -print)
total=$(echo -n "${javas}" | wc -l | xargs)
echo "Found ${total} Java files, starting to collect metrics..."

jobs=${TARGET}/temp/measure-jobs.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

declare -i file=0
echo -n "${javas}" | while read -r java; do
    file=$((file+1))
    javam="${java//${TARGET}\/github/${TARGET}\/measurements/}.m"
    if [ -e "${javam}" ]; then
        echo "Metrics already exist for $(basename "${java}") (${file}/${total})"
        continue
    fi
    echo "$(dirname "$0")/measure-file.sh" "${java}" "${javam}" "${file}" "${total}" >> "${jobs}"
done

uniq "${jobs}" | xargs -I {} -P "$(nproc)" "${SHELL}" -c "{}"
wait

echo "All metrics calculated in ${total} files in $(nproc) threads in $(echo "$(date +%s) - ${start}" | bc)s"
