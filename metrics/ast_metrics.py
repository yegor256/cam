#!/usr/bin/env python3
# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

"""ast_metrics.py"""

import sys

import javalang


def attrs(tlist) -> int:
    """

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


def sattrs(tlist) -> int:
    """

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


def ctors(tlist) -> int:
    """

    :rtype: int
    """
    declaration = tlist[0][1].filter(javalang.tree.ConstructorDeclaration)
    clist = list(method for method in declaration)
    return len(clist)


def methods(tlist) -> int:
    """

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


def smethods(tlist) -> int:
    """

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


def ncss(parser_class) -> int:
    """

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


def impls(tlist) -> int:
    """
    Count the number of interfaces the class implements.

    r:type: int
    """
    return len(tlist[0][1].implements or [])


if __name__ == '__main__':
    JAVA = sys.argv[1]
    metrics = sys.argv[2]
    with open(JAVA, encoding='utf-8', errors='ignore') as file:
        try:
            raw = javalang.parse.parse(file.read())
            tree = raw.filter(javalang.tree.ClassDeclaration)
            tree_class = list(value for value in tree)
            if not tree_class:
                raise Exception('This is not a class')
            with open(metrics, 'a', encoding='utf-8') as metric:
                metric.write(f'attributes {attrs(tree_class)} '
                             f'Number of Non-Static Attributes\n')
                metric.write(f'sattributes {sattrs(tree_class)} '
                             f'Number of Static Attributes\n')
                metric.write(f'ctors {ctors(tree_class)} '
                             f'Number of Constructors\n')
                metric.write(f'methods {methods(tree_class)} '
                             f'Number of Non-Static Methods\n')
                metric.write(f'smethods {smethods(tree_class)} '
                             f'Number of Static Methods\n')
                metric.write(f'ncss {ncss(raw)} '
                             f'Non Commenting Source Statements (NCSS)\n')
                metric.write(f'impls {impls(tree_class)} '
                             f'Number of implemented interfaces \n')
        except FileNotFoundError as exception:
            message = f"{type(exception).__name__} {str(exception)}: {JAVA}"
            sys.exit(message)
