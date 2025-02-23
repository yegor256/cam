#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    java="${temp}/Foo long 'weird' name (--).java"
    echo "@Demo public final class Foo<T> extends Bar implements Boom, Hello {
        final File a;
        static String Z;
        static float MY_CONSTANT_PI_WITH_LONG_NAME = 3.14159;
        private int camelCase123;
        void x() { }
        int y() { return 0; }
        void camelCaseMethod() { }
    }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    cat "${temp}/stdout"
    grep "NoOA 2 " "${temp}/stdout"
    grep "NoSA 2 " "${temp}/stdout"
    grep "NoCC 0 " "${temp}/stdout"
    grep "NoOM 3 " "${temp}/stdout"
    grep "NoII 2 " "${temp}/stdout"
    grep "NAPC 1 " "${temp}/stdout"
    grep "NoTP 1 " "${temp}/stdout"
    grep "Final 1 " "${temp}/stdout"
    grep "NoCA 1 " "${temp}/stdout"
    grep "PVN 2.75 " "${temp}/stdout"
    grep "PVNMx 6 " "${temp}/stdout"
    grep "PVNMN 1 " "${temp}/stdout"
    grep "PCN 1" "${temp}/stdout"
    grep "MHF 1.0 " "${temp}/stdout"
    grep "SMHF 0 " "${temp}/stdout"
    grep "AHF 0.25 " "${temp}/stdout"
    grep "SAHF 0.0 " "${temp}/stdout"
    grep "NoMP 0 " "${temp}/stdout"
    grep "NoSMP 0 " "${temp}/stdout"
    grep "NOMPMx 0 " "${temp}/stdout"
    grep "NOSMPMx 0 " "${temp}/stdout"
    grep "NOM 0 " "${temp}/stdout"
    grep "NOMR 0 " "${temp}/stdout"
    grep "NOP 0 " "${temp}/stdout"
    grep "NULLs 0 " "${temp}/stdout"
    grep "DOER 0.5 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly collected AST metrics"

{
    java="${temp}/Hello.java"
    echo "class Hello {
        String x() { return null; }
        String y() { return \"null\"; }
    }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    cat "${temp}/stdout"
    grep "NULLs 1 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly counted NULL references"

{
    if ! "${LOCAL}/metrics/ast.py" > "${temp}/message"; then
        grep "Usage: python ast.py <path to the .java file> <output file with metrics>" "${temp}/message"
    fi

    if ! "${LOCAL}/metrics/ast.py" "${java}" > "${temp}/message"; then
        grep "Usage: python ast.py <path to the .java file> <output file with metrics>" "${temp}/message"
    fi

    if ! "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout" "${temp}/stdout" > "${temp}/message"; then
        grep "Usage: python ast.py <path to the .java file> <output file with metrics>" "${temp}/message"
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Usage works correctly"

{
    java="${temp}/Hello.java"
    echo "class Hello {
        @Override
        String x() { return null; }
        String y() { return \"null\"; }
    }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    cat "${temp}/stdout"
    grep "NOM 1 " "${temp}/stdout"
    grep "NOMR 0.5 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated NOM and NOMR"
