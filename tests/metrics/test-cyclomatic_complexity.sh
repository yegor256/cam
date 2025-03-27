#!/usr/bin/env bash


# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

temp=$1
stdout=$2

{
    java="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /FooTest.java"
    mkdir -p "$(dirname "${java}")"
    echo "class Foo {}" > "${java}"
    "${LOCAL}/metrics/cyclomatic_complexity.py" "${java}" "${temp}/stdout"
    grep "CC 0 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated cyclomatic complexity for empty class"

{
    java="${temp}/foo/dir (with) _ long & and 'weird' \"name\" /FooTest.java"
    mkdir -p "$(dirname "${java}")"
    echo "public class SimpleControlFlow {
              public void checkNumber(int number) {
                  if (number > 0) {
                      System.out.println(\"The number is positive.\");
                  } else {
                      System.out.println(\"The number is not positive.\");
                  }
              }
          }" > "${java}"
    "${LOCAL}/metrics/cyclomatic_complexity.py" "${java}" "${temp}/stdout"
    grep "CC 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated cyclomatic complexity for single method class"

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

{
    java="${temp}/IfStatement.java"
    mkdir -p "$(dirname "${java}")"
    echo "public class IfStatement { public void test(int a) { if (a > 0) {} } }" > "${java}"
    "${LOCAL}/metrics/cyclomatic_complexity.py" "${java}" "${temp}/stdout"
    grep "CC 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 IfStatement works correctly"

{
    java="${temp}/ForStatement.java"
    mkdir -p "$(dirname "${java}")"
    echo "public class ForStatement { public void test() { for(int i=0; i<10; i++) {} } }" > "${java}"
    "${LOCAL}/metrics/cyclomatic_complexity.py" "${java}" "${temp}/stdout"
    grep "CC 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 ForStatement works correctly"

{
    java="${temp}/WhileStatement.java"
    mkdir -p "$(dirname "${java}")"
    echo "public class WhileStatement { public void test(int a) { while (a > 0) { a--; } } }" > "${java}"
    "${LOCAL}/metrics/cyclomatic_complexity.py" "${java}" "${temp}/stdout"
    grep "CC 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 WhileStatement works correctly"

{
    java="${temp}/DoWhileStatement.java"
    mkdir -p "$(dirname "${java}")"
    echo "public class DoWhileStatement { public void test(int a) { do { a--; } while (a > 0); } }" > "${java}"
    "${LOCAL}/metrics/cyclomatic_complexity.py" "${java}" "${temp}/stdout"
    grep "CC 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 DoWhileStatement works correctly"

{
    java="${temp}/BinaryOperation.java"
    mkdir -p "$(dirname "${java}")"
    echo "public class BinaryOperation { public void test(int a, int b) { if (a > 0 && b > 0) {} } }" > "${java}"
    "${LOCAL}/metrics/cyclomatic_complexity.py" "${java}" "${temp}/stdout"
    grep "CC 3 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 BinaryOperation works correctly"

{
    java="${temp}/TernaryExpression.java"
    mkdir -p "$(dirname "${java}")"
    echo "public class TernaryExpression { public int test(int a) { return (a > 0) ? 1 : 0; } }" > "${java}"
    "${LOCAL}/metrics/cyclomatic_complexity.py" "${java}" "${temp}/stdout"
    grep "CC 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 TernaryExpression works correctly"

{
    java="${temp}/MethodDeclaration.java"
    mkdir -p "$(dirname "${java}")"
    echo "public class MethodDeclaration { public void test() {} }" > "${java}"
    "${LOCAL}/metrics/cyclomatic_complexity.py" "${java}" "${temp}/stdout"
    grep "CC 1 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 MethodDeclaration works correctly"
