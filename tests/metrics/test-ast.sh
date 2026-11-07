#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
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
    grep "JDC 0.0 " "${temp}/stdout"
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

{
    java="${temp}/TestDoc.java"
    cat > "${java}" <<EOT
public class TestDoc {
    /**
     * This is a documented method.
     */
    public void documented() {}

    public void notDocumented() {}

    /**
     * Another documented method.
     */
    public void alsoDocumented() {}
}
EOT
    "${LOCAL}/metrics/ast.py" "${java}" "${temp}/stdout"
    cat "${temp}/stdout"
    grep "JDC 0.67 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍 Javadoc coverage was calculated correctly"

{
    python3 - "${temp}" "${LOCAL}" <<'PY'
import importlib.util
import pathlib
import runpy
import sys
from unittest.mock import patch

import javalang

folder = pathlib.Path(sys.argv[1])
script = pathlib.Path(sys.argv[2]) / 'metrics/ast.py'
spec = importlib.util.spec_from_file_location('cam_ast', script)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

# Each source isolates a semantic distinction; values are LCOM1 pair counts.
cases = [
    ('empty', 'class A {}', 0),
    ('one', 'class A { int x; void f() { x++; } }', 0),
    ('no-fields', 'class A { void f() {} void g() {} void h() {} }', 3),
    ('disjoint', 'class A { int x,y,z; void f(){x++;} void g(){y++;} void h(){z++;} }', 3),
    ('shared', 'class A { int x; void f(){x++;} void g(){x++;} void h(){x++;} }', 0),
    ('mixed', 'class A { int x,y; void f(){x++;} void g(){x++;} void h(){y++;} }', 1),
    ('clamped', 'class A { int x,y; void f(){x++;} void g(){x++;} void h(){x++;} void i(){y++;} }', 0),
    ('repeated', 'class A { int x; void f(){x++;x++;} void g(){x++;} void h(){} }', 1),
    ('locals', 'class A { int x; void f(){int x=1; use(x);} void g(){int x=2; use(x);} void h(){} }', 3),
    ('parameters', 'class A { int x; void f(int x){use(x);} void g(int x){use(x);} void h(){} }', 3),
    ('explicit-this', 'class A { int x; void f(int x){this.x=x;} void g(int x){this.x=x;} void h(){} }', 1),
    ('qualified-this', 'class A { int x; void f(int x){A.this.x=x;} void g(int x){A.this.x=x;} void h(){} }', 1),
    ('foreign-this', 'class A { int x; void f(){B.this.x++;} void g(){x++;} void h(){} }', 3),
    ('other-object', 'class A { int x; void f(A other){other.x++;} void g(A other){other.x++;} void h(){} }', 3),
    ('block-scope', 'class A { int x; void f(){{int x=1;} x++;} void g(){x++;} void h(){} }', 1),
    ('before-local', 'class A { int x; void f(){use(x); int x=1;} void g(){x++;} void h(){} }', 1),
    ('declarator-order', 'class A { int x; void f(){int y=x,x=1;} void g(){x++;} void h(){} }', 1),
    ('own-initializer', 'class A { int x; void f(){int x=x;} void g(){x++;} void h(){} }', 3),
    ('for-local', 'class A { int x; void f(){for(int x=0;x<2;x++){use(x);}} void g(){x++;} void h(){} }', 3),
    ('after-for', 'class A { int x; void f(){for(int x=0;x<2;x++){} x++;} void g(){x++;} void h(){} }', 1),
    ('foreach-local', 'class A { int x; void f(){for(int x:values){use(x);}} void g(){x++;} void h(){} }', 3),
    ('foreach-iterable', 'class A { int[] x; void f(){for(int x:x){use(x);}} void g(){use(x);} void h(){} }', 1),
    ('catch-local', 'class A { int x; void f(){try{} catch(Exception x){use(x);}} void g(){x++;} void h(){} }', 3),
    ('after-catch', 'class A { int x; void f(){try{} catch(Exception x){} x++;} void g(){x++;} void h(){} }', 1),
    ('resource-local', 'class A { R x; void f(){try(R x=open()){use(x);}} void g(){use(x);} void h(){} }', 3),
    ('resource-finally', 'class A { R x; void f(){try(R x=open()){} finally{use(x);}} void g(){use(x);} void h(){} }', 1),
    ('lambda-local', 'class A { int x; void f(){F r=x -> x+1;} void g(){x++;} void h(){} }', 3),
    ('typed-lambda', 'class A { int x; void f(){F r=(int x) -> x+1;} void g(){x++;} void h(){} }', 3),
    ('lambda-this', 'class A { int x; void f(){F r=x -> this.x;} void g(){x++;} void h(){} }', 1),
    ('lambda-capture', 'class A { int x; void f(){F r=() -> x;} void g(){x++;} void h(){} }', 1),
    ('lambda-scope', 'class A { int x; void f(){F r=x -> x; x++;} void g(){x++;} void h(){} }', 1),
    ('member-class', 'class A { int x; void f(){x++;} static class B { int y; void p(){} void q(){} void r(){} } }', 0),
    ('inner-fields', 'class A { void f(){use(y);} void g(){use(y);} void h(){} class B { int y; } }', 3),
    ('local-class', 'class A { int x; void f(){class B { void p(){x++;} }} void g(){x++;} void h(){} }', 3),
    ('local-shadow', 'class A { int x; void f(){class B { void p(){int x=0;} } x++;} void g(){x++;} void h(){} }', 1),
    ('anonymous', 'class A { int x; void f(){Object r=new Object(){int y=x; void p(){x++;}};} void g(){x++;} void h(){} }', 3),
    ('anonymous-argument', 'class A { int x; void f(){Object r=new B(x){void p(){}};} void g(){x++;} void h(){} }', 1),
    ('anonymous-selector', 'class A { int x; void f(){Object r=new B().new C(){void p(){x++;}};} void g(){x++;} void h(){} }', 3),
    ('anonymous-selector-arg', 'class A { int x; void f(){Object r=new B().new C(x){void p(){}};} void g(){x++;} void h(){} }', 1),
    ('anonymous-shadow', 'class A { int x; void f(){Object r=new B(){int x;}; x++;} void g(){x++;} void h(){} }', 1),
    ('constructors', 'class A { int x; A(){x++;} void f(){x++;} void g(){} }', 1),
    ('static-methods', 'class A { int x; static void p(){} static void q(){} void f(){x++;} }', 0),
    ('static-fields', 'class A { static int x; void f(){x++;} void g(){x++;} void h(){} }', 3),
    ('static-qualified', 'class A { static int x; void f(){A.x++;} void g(){A.x++;} void h(){} }', 3),
    ('receiver', 'class A { B x; void f(){x.go();} void g(){use(x.y);} void h(){} }', 1),
    ('receiver-shadow', 'class A { B x; void f(B x){x.go();} void g(B x){use(x.y);} void h(){} }', 3),
    ('this-chain', 'class A { B b; int x; void f(){this.b.x++;} void g(){x++;} void h(){} }', 3),
    ('call-chain', 'class A { int x; void f(){this.get().x++;} void g(){x++;} void h(){} }', 3),
    ('array-index', 'class A { int x; void f(){use(a[this.x]);} void g(){x++;} void h(){} }', 1),
    ('method-reference', 'class A { B x; void f(){F r=x::go;} void g(){use(x);} void h(){} }', 1),
    ('abstract', 'abstract class A { int x; abstract void f(); void g(){x++;} void h(){} }', 3),
    ('second-class', 'class A { int x; void f(){x++;} } class B { void p(){} void q(){} }', 0),
    ('synchronized-scope', 'class A { int x; void f(){synchronized(this){int x=1;} x++;} void g(){x++;} void h(){} }', 1),
    ('switch-scope', 'class A { int x; void f(){switch(0){case 0: int x=1; use(x);} x++;} void g(){x++;} void h(){} }', 1),
]
for name, source, expected in cases:
    tree = list(javalang.parse.parse(source).filter(javalang.tree.ClassDeclaration))
    actual = module.lcom(tree)
    assert actual == expected, (name, expected, actual)
    print(name, actual)

# Exercise the real entry point and ensure LCOM adds no second parse and no
# duplicate output. Append semantics must preserve existing metric lines.
java = folder / 'Lcom.java'
java.write_text(cases[3][1], encoding='utf-8')
output = folder / 'lcom.metrics'
output.write_text('Sentinel 42 Existing metric\n', encoding='utf-8')
with patch.object(sys, 'argv', [str(script), str(java), str(output)]):
    with patch.object(javalang.parse, 'parse', wraps=javalang.parse.parse) as parser:
        runpy.run_path(str(script), run_name='__main__')
        assert parser.call_count == 1, parser.call_count
lines = output.read_text(encoding='utf-8').splitlines()
assert lines[0] == 'Sentinel 42 Existing metric'
assert [line for line in lines if line.startswith('LCOM ')] == [
    'LCOM 3 Lack of Cohesion of Methods (LCOM1)'
]
assert any(line.startswith('CC ') for line in lines)
print('One parse, one LCOM line, existing AST metrics preserved')
PY
} > "${stdout}" 2>&1
echo "👍🏻 LCOM1 respects field resolution, lexical scopes and class boundaries"
