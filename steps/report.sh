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

if ! tlmgr --version >/dev/null 2>&1; then
  PATH=$PATH:$("${LOCAL}/help/texlive-bin.sh")
  export PATH
fi

list=${TARGET}/temp/list-of-metrics.tex
rm -f "${list}"
touch "${list}"

java=${TARGET}/temp/Foo.java
mkdir -p "$(dirname "${java}")"
find "${LOCAL}/metrics" -type f -exec test -x {} \; -exec basename {} \; | while IFS= read -r m; do
    echo "class Foo {}" > "${java}"
    metric=${TARGET}/temp/Foo.${m}.m
    rm -f "${metric}"
    "${LOCAL}/metrics/${m}" "${java}" "${metric}"
    awk '{ s= "\\item\\ff{" $1 "}: "; for (i = 3; i <= NF; i++) s = s $i " "; print s; }' < "${metric}" >> "${list}"
    echo "$(wc -l < "${metric}" | xargs) metrics from ${m}"
done

if [ ! -s "${list}" ]; then
    echo "No metric generating files found, probably an internal error"
    exit 1
fi

sort -o "${list}" "${list}"

# It's important to make sure the path is absolute, for LaTeX
t=$(realpath "${TARGET}")

tmp=${t}/temp/pdf-report
if [ -e "${tmp}" ]; then
    echo "Temporary directory for PDF report building already exists: '${tmp}'"
    latexmk -cd -C "${tmp}/report.tex"
    cp -r "${LOCAL}"/tex/ "${tmp}"
else
    mkdir -p "$(dirname "${tmp}")"
    cp -r "${LOCAL}/tex" "${tmp}"
    echo "Temporary directory for PDF report created: '${tmp}'"
fi

pdf=${tmp}/report.pdf
if [ -e "${pdf}" ]; then
    echo "The PDF report already exists: '${pdf}'"
    exit
fi

dest=${t}/report.pdf
if ! TARGET="${t}" latexmk -pdf -r "${tmp}/.latexmkrc" -quiet -cd "${tmp}/report.tex"; then
    log=${tmp}/report.log
    if [ -e "${log}" ]; then
        cat "${log}"
        echo "Failed to generate PDF report with LaTeX, see the log above (${log})"
    else
        echo "Failed to generate PDF report with LaTeX, there is no log file visible (${log})"
    fi
    exit 1
fi
cp "${pdf}" "${dest}"

echo "PDF report generated in ${dest} ($(du -k "${dest}" | cut -f1) Kb)"
