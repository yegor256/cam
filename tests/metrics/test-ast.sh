#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

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
    grep "AML 1.0 " "${temp}/stdout"
    grep "Getters 0 " "${temp}/stdout"
    grep "Setters 0 " "${temp}/stdout"
    grep "CC 3 " "${temp}/stdout"
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

{
    java="${temp}/TestAML.java"
    echo "public class TestAML {
        public void shortMethod() { int a = 1; }
        public void longMethod() {
            System.out.println(\"Line 1\");
            System.out.println(\"Line 2\");
            System.out.println(\"Line 3\");
        }
    }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    cat "${temp}/stdout"
    grep "AML 3.0 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated AML for default class"

{
    java="${temp}/EmptyTest.java"
    echo "public class EmptyClass {
    }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    cat "${temp}/stdout"
    grep "AML 0.0 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated AML for empty class"

{
    java="${temp}/Person.java"
    echo "public class Person {
        private String name;
        private int age;
        public String getName() {return this.name;}
        public void setName(String name) {this.name = name;}
        public int getAge() {return this.age;}
        public void setAge(int age) {this.age = age;}
        public void nonAccessorMethod() {
            if (age > 18) {System.out.println(\"Adult\");}
        }
    }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    cat "${temp}/stdout"
    grep "Getters 2 " "${temp}/stdout"
    grep "Setters 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated Getter & Setter complexity"

{
    java="${temp}/FooTest.java"
    echo "class Foo {}" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    cat "${temp}/stdout"
    grep "CC 0 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated Cyclomatic Complexity for empty class"

{
    java="${temp}/SimpleControlFlow.java"
    echo "public class SimpleControlFlow {
              public void checkNumber(int number) {
                  if (number > 0) {
                      System.out.println(\"The number is positive.\");
                  } else {
                      System.out.println(\"The number is not positive.\");
                  }
              }
          }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    cat "${temp}/stdout"
    grep "CC 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated Cyclomatic Complexity for single method class"

{
    java="${temp}/IfStatement.java"
    echo "public class IfStatement { public void test(int a) { if (a > 0) {} } }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    grep "CC 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 IfStatement works correctly for Cyclomatic Complexity"

{
    java="${temp}/ForStatement.java"
    echo "public class ForStatement { public void test() { for(int i=0; i<10; i++) {} } }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    grep "CC 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 ForStatement works correctly for Cyclomatic Complexity"

{
    java="${temp}/WhileStatement.java"
    echo "public class WhileStatement { public void test(int a) { while (a > 0) { a--; } } }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    grep "CC 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 WhileStatement works correctly for Cyclomatic Complexity"

{
    java="${temp}/DoWhileStatement.java"
    echo "public class DoWhileStatement { public void test(int a) { do { a--; } while (a > 0); } }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    grep "CC 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 DoWhileStatement works correctly for Cyclomatic Complexity"

{
    java="${temp}/BinaryOperation.java"
    echo "public class BinaryOperation { public void test(int a, int b) { if (a > 0 && b > 0) {} } }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    grep "CC 3 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 BinaryOperation works correctly for Cyclomatic Complexity"

{
    java="${temp}/TernaryExpression.java"
    echo "public class TernaryExpression { public int test(int a) { return (a > 0) ? 1 : 0; } }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    grep "CC 2 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 TernaryExpression works correctly for Cyclomatic Complexity"

{
    java="${temp}/MethodDeclaration.java"
    echo "public class MethodDeclaration { public void test() {} }" > "${java}"
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    grep "CC 1 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 MethodDeclaration works correctly for Cyclomatic Complexity"