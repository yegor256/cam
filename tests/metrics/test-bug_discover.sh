#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    pmd --version
    xmllint --version
} > "${stdout}" 2>&1
echo "👍🏻 PMD dependencies are installed"

{
    java="${temp}/Foo long 'weird' name (--).java"
    echo "
    public class StaticField {
        static int x;
        public FinalFields(int y) {
            x = y; // unsafe
        }
    }" > "${java}"
    "${LOCAL}/metrics/bug_discover.sh" "${java}" "${temp}/stdout"
    grep "BugNum 1 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculates the bug discovery metric"
