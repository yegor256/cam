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

mkdir -p "${TARGET}/temp/reports"
find "${LOCAL}/filters" -type f -name '*.sh' -exec bash -c 'realpath --relative-to="${1}" "$2"' _ "${LOCAL}/filters" {} \; | sort | while IFS= read -r filter; do
    tex=${TARGET}/temp/reports/${filter}.tex
    if [ ! -s "${tex}" ]; then
        echo "The ${filter} filter failed in previous run, cleaning up after it now..."
        rm -f "${tex}"
    fi
    if [ -e "${tex}" ]; then
        echo "The ${filter} filter was already completed earlier, see report in '${tex}'"
    else
        before=$(find "${TARGET}/github" -name '*' -type f -o -type l -o -type d | wc -l | xargs)
        echo "Running filter ${filter}... (may take some time)"
        start=$(date +%s%N)
        "${LOCAL}/filters/${filter}" "${TARGET}/github" "${TARGET}/temp" |\
            tr -d '\n\r' |\
            sed "s/^/\\\\item /" |\
            sed "s/$/;/" \
            > "${tex}"
        after=$(find "${TARGET}/github" -name '*' -type f -o -type l -o -type d | wc -l | xargs)
        if [ "${after}" -lt "${before}" ]; then
            diff="deleted $(echo "${before} - ${after}" | bc) files"
        elif [ "${after}" -gt "${before}" ]; then
            diff="added $(echo "${after} - ${before}" | bc) files"
        else
            diff="didn't touch any files"
        fi
        echo "Filter ${filter} finished$("${LOCAL}/help/tdiff.sh" "${start}"), ${diff} \
and published its results to ${TARGET}/temp/reports/${filter}.tex "
    fi
done

find "${TARGET}/temp/reports" -type f -exec basename {} \; | sort | while IFS= read -r f; do
    echo "${f}:"
    cat "${TARGET}/temp/reports/${f}"
    echo ""
done
