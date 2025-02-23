#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    java="${temp}/Foo long 'weird' name (--).java"
    echo "class Foo {}" > "${java}"
    "${LOCAL}/metrics/cloc.sh" "${java}" "${temp}/stdout"
    grep "LoC 1 " "${temp}/stdout"
    grep "NoBL 0 " "${temp}/stdout"
    grep "NoCL 0 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly counted lines of code"
