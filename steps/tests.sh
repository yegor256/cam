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

temp=${LOCAL}/test-zone
mkdir -p "${temp}"

export CAMTESTS=1

find "${LOCAL}/tests" -type f -name '*.sh' | sort | while IFS= read -r test; do
    name=$(realpath --relative-to="${LOCAL}/tests" "${test}")
    if [ -n "${TEST}" ] && [ ! "${TEST}" = "${name}" ] && [ ! "${TEST}" = "tests/${name}" ]; then
        continue
    fi
    echo -e "\n${name}:"
    t=${temp}/${name}
    if [ -e "${t}" ]; then
        rm -rf "${t}"
    fi
    mkdir -p "${t}"
    tgt=${t}/target
    if [ -e "${tgt}" ]; then
        rm -rf "${tgt}"
    fi
    mkdir -p "${tgt}"
    stdout=${t}/stdout.log
    mkdir -p "$(dirname "${stdout}")"
    touch "${stdout}"
    if ! TARGET="${tgt}" "${test}" "${t}" "${stdout}"; then
        cat "${stdout}"
        echo "❌ Non-zero exit code (TARGET=${tgt})"
        exit 1
    fi
done
