#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import re
import sys
from typing import Any, Final

import javalang


def doer(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> float:
    """Ratio of the quantity of attributes that are data primitives and those that are pointers to objects.
    :rtype: float
    """
    declaration = tlist[0][1].filter(javalang.tree.FieldDeclaration)
    fields = list(field for field in declaration)
    num_primitives = 0
    num_pointers = 0

    for path, node in fields:
        del path
        if node.type.name in ['int', 'float', 'double', 'boolean', 'char', 'byte', 'short', 'long']:
            num_primitives += 1
        else:
            num_pointers += 1

    if (total := num_primitives + num_pointers) == 0:
        return 0
    return num_primitives / total


def ahf(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> float:
    """Ratio of private/protected attributes to all attributes in a class.
    :rtype: float
    """
    declaration = tlist[0][1].filter(javalang.tree.FieldDeclaration)
    fields = list(field for field in declaration)
    hidden = 0
    total = 0
    for path, node in fields:
        del path
        if 'private' in node.modifiers or 'protected' in node.modifiers:
            hidden += 1
        total += 1
    if total == 0:
        return 0
    return hidden / total


def sahf(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> float:
    """Ratio of private/protected attributes to static attributes in a class.
    :rtype: float
    """
    declaration = tlist[0][1].filter(javalang.tree.FieldDeclaration)
    fields = list(field for field in declaration)
    hidden = 0
    total = 0
    for path, node in fields:
        del path
        if 'static' not in node.modifiers:
            continue
        if 'private' in node.modifiers or 'protected' in node.modifiers:
            hidden += 1
        total += 1
    if total == 0:
        return 0
    return hidden / total


def nomp(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Total number of parameters in all class methods.
    :rtype: int
    """
    declaration = tlist[0][1].filter(javalang.tree.MethodDeclaration)
    mlist = list(method for method in declaration)
    total = 0
    for path, node in mlist:
        del path
        total += len(node.parameters)
    return total


def nosmp(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Total number of parameters in static class methods.
    :rtype: int
    """
    declaration = tlist[0][1].filter(javalang.tree.MethodDeclaration)
    mlist = list(method for method in declaration)
    total = 0
    for path, node in mlist:
        del path
        if 'static' not in node.modifiers:
            continue
        total += len(node.parameters)
    return total


def nompmx(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Maximum number of parameters in all class methods.
    :rtype: int
    """
    declaration = tlist[0][1].filter(javalang.tree.MethodDeclaration)
    mlist = list(method for method in declaration)
    maximum = 0
    for path, node in mlist:
        del path
        maximum = max(maximum, len(node.parameters))
    return maximum


def nosmpmx(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Maximum number of parameters in static class methods.
    :rtype: int
    """
    declaration = tlist[0][1].filter(javalang.tree.MethodDeclaration)
    mlist = list(method for method in declaration)
    maximum = 0
    for path, node in mlist:
        del path
        if 'static' not in node.modifiers:
            continue
        maximum = max(maximum, len(node.parameters))
    return maximum


def nom(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Number of methods that are annotated with @Override.
    :rtype: int
    """
    declaration = tlist[0][1].filter(javalang.tree.MethodDeclaration)
    mlist = list(method for method in declaration)
    total = 0
    for path, node in mlist:
        del path
        annotations = list(annotation.name for annotation in node.annotations)
        if 'Override' in annotations:
            total += 1
    return total


def nomr(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> float:
    """Number of methods that are annotated with @Override divided by total number of methods.
    :rtype: float
    """
    if (total_methods_number := total_methods(tlist)) == 0:
        return 0
    if (nom_result := nom(tlist)) == 0:
        return 0
    return nom_result / total_methods_number


def attrs(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Count non-static attributes.
    :rtype: int
    """
    declaration = tlist[0][1].filter(javalang.tree.FieldDeclaration)
    fields = list(field for field in declaration)
    found = 0
    for path, node in fields:
        del path
        if 'static' not in node.modifiers:
            found += 1
    return found


def sattrs(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Count static attributes.
    :rtype: int
    """
    declaration = tlist[0][1].filter(javalang.tree.FieldDeclaration)
    fields = list(field for field in declaration)
    found = 0
    for path, node in fields:
        del path
        if 'static' in node.modifiers:
            found += 1
    return found


def ctors(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Count constructors.
    :rtype: int
    """
    declaration = tlist[0][1].filter(javalang.tree.ConstructorDeclaration)
    clist = list(method for method in declaration)
    return len(clist)


def methods(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Count non-static methods.
    :rtype: int
    """
    declaration = tlist[0][1].filter(javalang.tree.MethodDeclaration)
    mlist = list(method for method in declaration)
    found = 0
    for path, node in mlist:
        del path
        if 'static' not in node.modifiers:
            found += 1
    return found


def smethods(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Count static methods.
    :rtype: int
    """
    declaration = tlist[0][1].filter(javalang.tree.MethodDeclaration)
    mlist = list(method for method in declaration)
    found = 0
    for path, node in mlist:
        del path
        if 'static' in node.modifiers:
            found += 1
    return found


def total_methods(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Count total number methods.
    :rtype: int
    """
    declaration = list(tlist[0][1].filter(javalang.tree.MethodDeclaration))
    return len(declaration)


def mhf(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> float:
    """Calculate Method Hiding Factor (MHF), which is the ratio
    between private+protected methods and all methods.
    :rtype: float
    """
    declaration = tlist[0][1].filter(javalang.tree.MethodDeclaration)
    mlist = list(method for method in declaration)
    hidden = 0
    total = 0
    for path, node in mlist:
        del path
        if 'public' not in node.modifiers:
            hidden += 1
        total += 1
    if total == 0:
        return 0
    return hidden / total


def smhf(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> float:
    """Calculate Static Method Hiding Factor (SMHF), which is the ratio
    between private+protected methods and all methods (which are static).
    :rtype: float
    """
    declaration = tlist[0][1].filter(javalang.tree.MethodDeclaration)
    mlist = list(method for method in declaration)
    hidden = 0
    total = 0
    for path, node in mlist:
        del path
        if 'static' not in node.modifiers:
            continue
        if 'public' not in node.modifiers:
            hidden += 1
        total += 1
    if total == 0:
        return 0
    return hidden / total


def ncss(parser_class: javalang.tree.CompilationUnit) -> int:
    """Count the NCSS (non-commenting source statement) lines.
    :rtype: int
    """
    value = 0
    for path, node in parser_class:
        del path
        node_type = str(type(node))
        if 'Statement' in node_type:
            value += 1
        elif node_type == 'VariableDeclarator':
            value += 1
        elif node_type == 'Assignment':
            value += 1
        elif 'Declaration' in node_type \
                and 'LocalVariableDeclaration' not in node_type \
                and 'PackageDeclaration' not in node_type:
            value += 1
    return value


def impls(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Count the number of interfaces the class implements.
    r:type: int
    """
    return len(tlist[0][1].implements or [])


def extnds(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Count the number of classes this class extends (0 or 1).
    r:type: int
    """
    return 0 if tlist[0][1].extends is None else 1


def final(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Return 1 if the class is final, zero otherwise.
    r:type: int
    """
    return 1 if 'final' in tlist[0][1].modifiers else 0


def gnrcs(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Return number of type parameters (generics).
    r:type: int
    """
    return len(tlist[0][1].type_parameters or [])


def annts(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Return number of annotations of the class.
    r:type: int
    """
    return len(tlist[0][1].annotations or [])


def _components_number(name: str) -> int:
    """Return number of parts in variable name.
       Variables are split considering "$" and "_" symbols, snake_case and camelCase naming conventions.
    r:type: int
    """
    parts = 0
    components = [comp for comp in re.split(r'[\$_]+', name) if comp != '']
    for component in components:
        parts += 1
        prev_char = component[:1]
        for char in component[1:]:
            if prev_char.isdigit() != char.isdigit() or (prev_char.islower() and char.isupper()):
                parts += 1
            prev_char = char
    if len(components) == 0:
        parts += 1
    return parts


def pvn(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> float:
    """Return average number of parts in variable names in class.
    r:type: float
    """
    parts = 0
    variables = 0
    for _, node in tlist[0][1].filter(javalang.tree.VariableDeclarator):
        if (name := node.name) == '':
            continue
        variables += 1
        parts += _components_number(name)
    return (parts / variables) if variables != 0 else 0


def pvnmx(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Return maximum number of parts in variable names in class.
    r:type: int
    """
    max_parts = 0
    for _, node in tlist[0][1].filter(javalang.tree.VariableDeclarator):
        if (name := node.name) == '':
            continue
        name_parts = _components_number(name)
        max_parts = max(name_parts, max_parts)
    return max_parts


def pvnmn(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Return minimun number of parts in variable names in class.
    r:type: int
    """
    min_parts = 0
    for _, node in tlist[0][1].filter(javalang.tree.VariableDeclarator):
        if (name := node.name) == '':
            continue
        name_parts = _components_number(name)
        if min_parts == 0 or name_parts < min_parts:
            min_parts = name_parts
    return min_parts


def pcn(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Return number of words in the name of a class.
    r:type: int
    """
    classname = tlist[0][1].name
    # By naming convention Java classes names use PascalCase.
    # Nevertheless, this metric considers both PascalCasse and camelCase naming conventions.
    words = re.findall(r'[A-Z]?[a-z]+|[A-Z]+(?=[A-Z]|$)', classname)
    return len(words)


def nop(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Return number of polymorphic methods in main class.
    Methods of nested classes are skipped.
    r:type: int
    """
    declaration = tlist[0][1].filter(javalang.tree.MethodDeclaration)
    methods_count: dict[str, int] = {}

    for path, node in declaration:
        # Methods of nested classes has path > 2.
        if len(path) > 2:
            continue
        if node.name in methods_count:
            methods_count[node.name] += 1
            continue
        methods_count[node.name] = 1
    return sum(1 for count in methods_count.values() if count > 1)


def nulls(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Return number of null references used in the class.
    r:type: int
    """
    null_count = 0
    for _, node in tlist[0][1].filter(javalang.tree.Literal):
        if str(node.value) == 'null':
            null_count += 1
    return null_count


class NotClassError(Exception):
    """If it's not a class"""


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python ast.py <path to the .java file> <output file with metrics>")
        sys.exit(1)

    java: Final[str] = sys.argv[1]
    metrics: Final[str] = sys.argv[2]
    with open(java, encoding='utf-8', errors='ignore') as file:
        try:
            raw = javalang.parse.parse(file.read())
            tree = raw.filter(javalang.tree.ClassDeclaration)
            if not (tree_class := list((value for value in tree))):
                raise NotClassError('This is not a class')
            with open(metrics, 'a', encoding='utf-8') as metric:
                metric.write(f'NoOA {attrs(tree_class)} '
                             f'Number of Non-Static (Object) Attributes\n')
                metric.write(f'NoSA {sattrs(tree_class)} '
                             f'Number of Static Attributes\n')
                metric.write(f'NoCC {ctors(tree_class)} '
                             f'Number of Class Constructors\n')
                metric.write(f'NoOM {methods(tree_class)} '
                             f'Number of Non-Static (Object) Methods\n')
                metric.write(f'NoCM {smethods(tree_class)} '
                             f'Number of Static (Class) Methods\n')
                metric.write(f'NCSS {ncss(raw)} '
                             f'Non-Commenting Source Statements (NCSS). This metric that measures the number of lines'
                             f'in source code that are not comments or blank lines. It focuses on the actual executable'
                             f'statements in the code, excluding any documentation or formatting lines.\n')
                metric.write(f'NoII {impls(tree_class)} '
                             f'Number of Implemented Interfaces\n')
                metric.write(f'NAPC {extnds(tree_class)} '
                             f'Number of Ancestor (Parent) Classes\n')
                metric.write(f'NoTP {gnrcs(tree_class)} '
                             f'Number of Type Parameters (Generics)\n')
                metric.write(f'Final {final(tree_class)} '
                             f'Class is ``final\'\' (1) or not (0)\n')
                metric.write(f'NoCA {annts(tree_class)} '
                             f'Number of Class Annotations\n')
                metric.write(f'PVN {pvn(tree_class)} '
                             f'Average number of parts in variable names\n')
                metric.write(f'PVNMx {pvnmx(tree_class)} '
                             f'Maximum number of parts in variable names\n')
                metric.write(f'PVNMN {pvnmn(tree_class)} '
                             f'Minimum number of parts in variable names\n')
                metric.write(f'PCN {pcn(tree_class)} '
                             f'Number of words in the name of a class\n')
                metric.write(f'MHF {mhf(tree_class)} '
                             f'Method Hiding Factor (MHF), which is the ratio of private \
                             and protected methods to total methods\n')
                metric.write(f'SMHF {smhf(tree_class)} '
                             f'Static Method Hiding Factor (MHF), which is the ratio of private \
                             and protected static methods to total static methods\n')
                metric.write(f'AHF {ahf(tree_class)} '
                             f'Attribute Hiding Factor (AHF), which is the ratio of private \
                             and protected attributes to total attributes\n')
                metric.write(f'SAHF {sahf(tree_class)} '
                             f'Static Attribute Hiding Factor (SAHF), which is the ratio of private \
                             and protected static attributes to total static attributes\n')
                metric.write(f'NoMP {nomp(tree_class)} '
                             f'Number of Method Parameters (NOMP), which is the count of \
                             all parameters in all methods in a class\n')
                metric.write(f'NoSMP {nosmp(tree_class)} '
                             f'Number of Static Method Parameters (NOSMP), which is the count of all \
                             parameters in all static methods in a class\n')
                metric.write(f'NOMPMx {nompmx(tree_class)} '
                             f'Maximum of Method Parameters (NOMPMx), which is the largest amount \
                             of parameters in some method in a class\n')
                metric.write(f'NOSMPMx {nosmpmx(tree_class)} '
                             f'Maximum of Static Method Parameters (NOSMPMx), which is the largest \
                             amount of parameters in some static method in a class\n')
                metric.write(f'NOM {nom(tree_class)} '
                             f'Number of Overriding Methods (NOM), which is the number of methods \
                             with the \\texttt{{@Override}} annotation\n')
                metric.write(f'NOMR {nomr(tree_class)} '
                             f'Number of Overriding Methods Ratio (NOMR), which is the number of methods \
                                             with the \\texttt{{@Override}} annotation divided by '
                             f'total number of methods\n')
                metric.write(f'NOP {nop(tree_class)} '
                             f'Number of Polymorphic Methods (NOP), which is the count of methods \
                             that are overloaded at least once --- have similar names but different parameters\n')
                metric.write(f'NULLs {nulls(tree_class)} '
                             f'Number of references that are NULL by default in a given class \n')
                metric.write(f'DOER {doer(tree_class)} '
                             f'Data vs Object Encapsulation Ratio (DOER). This metric represents the ratio of'
                             f'attributes that store primitive data types (e.g., int, char, boolean) to the total'
                             f'number of attributes in a class. It provides insight into the balance between simple'
                             f'data storage (primitives) and references to more complex objects (references).\n')
        except FileNotFoundError as exception:
            message = f"{type(exception).__name__} {str(exception)}: {java}"
            sys.exit(message)
