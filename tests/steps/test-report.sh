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

if ! tlmgr --version >/dev/null 2>&1; then
  PATH=$PATH:$("${LOCAL}/help/texlive-bin.sh")
  export PATH
fi

{
    pdflatex -v
    pdftotext -v
    latexmk --version
} > "${stdout}" 2>&1
echo "👍🏻 Dependencies are available"

{
    date +%s%N > "${TARGET}/start.txt"
    mkdir -p "${TARGET}/temp"
    printf '%s' "repo,branch\nyegor256/jaxec,master" > "${TARGET}/repositories.csv"
    echo "nothing" > "${TARGET}/temp/repo-details.tex"
    mkdir -p "${TARGET}/temp/reports"
    mkdir -p "${TARGET}/data"
    mkdir -p "${TARGET}/github"
    echo "\\item foo" > "${TARGET}/temp/reports/foo.tex"
    "${LOCAL}/steps/report.sh"
    test -e "${TARGET}/report.pdf"
    pdftotext "${TARGET}/report.pdf" "${TARGET}/report.txt"
    txt=$(cat "${TARGET}/report.txt")
    echo "${txt}" | grep "yegor256/cam"
} > "${stdout}" 2>&1
echo "👍🏻 A PDF report generated correctly"

{
    while IFS= read -r t; do
        metric=$(echo "${t}" | cut -f1 -d' ')
        echo "${metric}" | grep '^\\item\\ff{[a-zA-Z0-9-]\+}:$' > /dev/null
    done < "${TARGET}/temp/list-of-metrics.tex"
} > "${stdout}" 2>&1
echo "👍🏻 A list of metrics is properly formatted"
