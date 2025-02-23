#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
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
    : > "${TARGET}/temp/jpeek_failure.log"
    : > "${TARGET}/temp/jpeek_success.log"
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
    done < "${TARGET}/temp/list-of-metrics.tex.unstructured"
} > "${stdout}" 2>&1
echo "👍🏻 A list of metrics is properly formatted"

{
    mkdir -p "${TARGET}/temp/test_metric"
    test_metric_sh="#!/bin/bash\n\n"
    test_metric_sh+="output=\$(realpath \"\$2\")\n"
    test_metric_sh+="for idx in {2..5}; do\n"
    test_metric_sh+="    echo \"Test-\${idx} 0 [Test group \$((idx % 2))] Test metrics\" >> \"\${output}\"\n"
    test_metric_sh+="done\n"
    printf "%b" "$test_metric_sh" > "${TARGET}/temp/test_metric/group_test.sh"
    chmod +x "${TARGET}/temp/test_metric/group_test.sh"
    LOCAL_METRICS="${TARGET}/temp/test_metric" "${LOCAL}/steps/report.sh"
    test -e "${TARGET}/report.pdf"
    pdftotext "${TARGET}/report.pdf" "${TARGET}/report.txt"
    txt=$(cat "${TARGET}/report.txt")
    actual=$(echo "${txt}" | grep -c '.*Test group [0-9]\+')
    if [ "$actual" != "2" ]; then
        echo "Exactly 2 test group names were expected, but ${actual} were actually found"
        exit 1
    fi
    awk '
        /Test group 0/ { in_group_0 = 1; in_group_1 = 0 }
        /Test group 1/ { in_group_0 = 0; in_group_1 = 1 }
        in_group_0 && /Test-(2|4): Test metrics/ { group_0_valid++ }
        in_group_1 && /Test-(3|5): Test metrics/ { group_1_valid++ }
        END {
            if (group_0_valid != 2 || group_1_valid != 2) {
                printf "Expected 2 valid metrics in each group, but found %d in group 0 and %d in group 1\n", group_0_valid, group_1_valid
                exit 1
            }
        }
    ' <<< "$txt"
} > "${stdout}" 2>&1
echo "👍🏻 Grouping is properly formatted for the list of metrics."
