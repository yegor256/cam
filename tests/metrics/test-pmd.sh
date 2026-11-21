#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

temp=$1
stdout=$2

{
    pmd --version
    xmllint --version
    ruby --version
} > "${stdout}" 2>&1
echo "👍🏻 PMD dependencies are installed"

{
    echo '<?xml version="1.0"?>
    <ruleset name="cam" xmlns="http://pmd.sourceforge.net/ruleset/2.0.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://pmd.sourceforge.net/ruleset/2.0.0 https://pmd.sourceforge.io/ruleset_2_0_0.xsd">
    </ruleset>' > "${temp}/config.xml"
    java="${temp}/Foo.java"
    mkdir -p "$(dirname "${java}")"
    echo "class Foo {}" > "${java}"
    pmd check -R "${temp}/config.xml" -d "$(dirname "${java}")" > "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 PMD tool works correctly"

{
    java="${temp}/Foo long 'weird' name (--).java"
    mkdir -p "$(dirname "${java}")"
    echo "class Foo {}" > "${java}"
    "${LOCAL}/metrics/pmd.sh" "${java}" "${temp}/stdout"
    grep "^CoCo 0 " "${temp}/stdout"
    grep "^ACoCo 0 " "${temp}/stdout"
    grep "^CoCoMx 0 " "${temp}/stdout"
    grep "^CoCoMn 0 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated cognitive complexity"

{
    cat > "${java}" <<'JAVA'
class Foo {
    int simple(int value) {
        if (value > 0) {
            return value;
        }
        return 0;
    }
    int nested(int value) {
        if (value > 0) {
            if (value > 1) {
                return value;
            }
        }
        return 0;
    }
}
JAVA
    "${LOCAL}/metrics/pmd.sh" "${java}" "${temp}/stdout"
    grep "^CoCo 4 " "${temp}/stdout"
    grep "^ACoCo 2 " "${temp}/stdout"
    grep "^CoCoMx 3 " "${temp}/stdout"
    grep "^CoCoMn 1 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly aggregates nonzero cognitive complexity"
