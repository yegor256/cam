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

stdout=$2

declare -a excludes=()
for e in dataset lib pylint_plugins venv; do
    excludes+=(-not -path "${LOCAL}/${e}/**")
done

{
    scripts=$(find "${LOCAL}" "${excludes[@]}" -type f -name '*.sh')
    echo "${scripts}" | while IFS= read -r sh; do
        if [ ! -x "${sh}" ]; then
            echo "Script '${sh}' is not executable, try running 'chmod +x ${sh}'"
            exit 1
        fi
    done
    echo "All $(echo "${scripts}" | wc -w | xargs) scripts are executable, it's OK"
} > "${stdout}" 2>&1
echo "👍🏻 All .sh scripts are executable"

{
    scripts=$(find "${LOCAL}" "${excludes[@]}" -type f -name '*.py')
    echo "${scripts}" | while IFS= read -r py; do
        if [ ! -x "${py}" ]; then
            echo "Script '${py}' is not executable, try running 'chmod +x ${py}'"
            exit 1
        fi
    done
    echo "All $(echo "${scripts}" | wc -w | xargs) scripts are executable, it's OK"
} > "${stdout}" 2>&1
echo "👍🏻 All .py scripts are executable"
