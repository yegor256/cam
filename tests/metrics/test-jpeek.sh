#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    if ! javac -version; then
        echo "Java is not installed, that's why can't run this test"
        exit 1
    fi
    if ! mvn --version; then
        echo "Maven is not installed, that's why can't run this test"
        exit 1
    fi
    if ! gradle --version; then
        echo "Gradle is not installed, that's why can't run this test"
        exit 1
    fi
    if ! java -jar "${JPEEK}" --help; then
        echo "jPeek JAR is not available at '${JPEEK}'"
        exit 1
    fi
} > "${stdout}" 2>&1
echo "👍🏻 jPeek dependencies are installed"

{
    java="${TARGET}/github/foo/bar/Foo.java"
    mkdir -p "$(dirname "${java}")"
    echo "class Foo {}" > "${java}"
    "${LOCAL}/metrics/jpeek.sh" "${java}" "${temp}/stdout"
    test ! -e "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly ignored metrics generation"

{
    java="${TARGET}/temp/Test.java"
    mkdir -p "$(dirname "${java}")"
    echo "class Foo {}" > "${java}"
    "${LOCAL}/metrics/jpeek.sh" "${java}" "${temp}/stdout"
    test -e "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly generated metrics description"
