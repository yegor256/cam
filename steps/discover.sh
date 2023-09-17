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

csv="${TARGET}/repositories.csv"
echo "" > "${TARGET}/temp/repo-details.tex"
if [ -e "${csv}" ]; then
    echo "The list of repos is already here: ${csv}"
elif [ ! -z "${REPO}" ]; then
    echo "Using one repo: ${REPO}"
    echo "${REPO}" >> "${csv}"
elif [ -z "${REPOS}" ] || [ ! -e "${REPOS}" ]; then
    echo "Using discover-repos.rb..."
    ruby "${HOME}/discover-repos.rb" \
        "--token=${TOKEN}" \
        "--total=${TOTAL}" \
        "--path=${csv}" \
        "--tex=${TARGET}/temp/repo-details.tex" \
        "--min-stars=400" \
        "--max-stars=10000"
else
    echo "Using repos list of csv..."
    cat "${REPOS}" >> "${csv}"
fi
cat "${csv}"
