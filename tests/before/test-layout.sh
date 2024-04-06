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

{
    dirs=$(find "${LOCAL}/tests" -mindepth 1 -maxdepth 1 -type d -not -name "before" -not -name "after" -exec basename {} \;)
    echo "${dirs}" | while IFS= read -r d; do
        tests=$(find "${LOCAL}/tests/${d}" -mindepth 1 -maxdepth 1 -type f -name '*.sh' -exec basename {} \;)
        echo "${tests}" | while IFS= read -r t; do
            tail=${t:5:100}
            base=${tail%.*}
            name=${d}/${tail}
            if [ "$(find "${LOCAL}/${d}" -name "${base}.*" 2>/dev/null | wc -l)" -eq 0 ]; then
                echo "Script '${name}' doesn't exist, but its test exists in '${LOCAL}/tests/${d}/${t}'"
                exit 1
            fi
        done
    done
} > "${stdout}" 2>&1
echo "👍🏻 All test scripts have their live counterparts"
