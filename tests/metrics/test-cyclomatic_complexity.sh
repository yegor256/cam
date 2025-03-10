#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    java="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /FooTest.java"
    mkdir -p "$(dirname "${java}")"
    echo "class Foo {}" > "${java}"
    "${LOCAL}/metrics/cyclomatic_complexity.py" "${java}" "${temp}/stdout"
    grep "CC 1 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated cyclomatic complexity"

{
    if ! "${LOCAL}/metrics/cyclomatic_complexity.py" > "${temp}/message"; then
        grep "Usage: python cyclomatic_complexity.py <path to the .java file> <output file with metrics>" "${temp}/message"
    fi

    if ! "${LOCAL}/metrics/cyclomatic_complexity.py" "${java}" > "${temp}/message"; then
        grep "Usage: python cyclomatic_complexity.py <path to the .java file> <output file with metrics>" "${temp}/message"
    fi

    if ! "${LOCAL}/metrics/cyclomatic_complexity.py" "${java}" "${temp}/stdout" "${temp}/stdout" > "${temp}/message"; then
        grep "Usage: python cyclomatic_complexity.py <path to the .java file> <output file with metrics>" "${temp}/message"
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Usage works correctly"
