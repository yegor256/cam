#!/usr/bin/env python
# The MIT License (MIT)
#
# Copyright (c) 2021 Yegor Bugayenko
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

"""Module's name is ast_metrics"""

import sys

import javalang


def attrs(tree_list):
    """

    :rtype: int
    """
    fields = tree_list[0][1].filter(javalang.tree.FieldDeclaration)
    flist = list(field for field in fields)
    found = 0
    for path, node in flist:
        if 'static' in node.modifiers:
            continue
        found += 1
    return found


def sattrs(tree_list):
    """

    :rtype: int
    """
    fields = tree_list[0][1].filter(javalang.tree.FieldDeclaration)
    flist = list(field for field in fields)
    found = 0
    for path, node in flist:
        if 'static' in node.modifiers:
            found += 1
    return found


def ctors(tree_list):
    """

    :rtype: int
    """
    mlist = tree_list[0][1].filter(javalang.tree.ConstructorDeclaration)
    clist = list(method for method in mlist)
    return len(clist)


def methods(tree_list):
    """

    :rtype: int
    """
    mlist = list(method for method in tree_list[0][1]
                 .filter(javalang.tree.MethodDeclaration))
    found = 0
    for path, node in mlist:
        if 'static' in node.modifiers:
            continue
        found += 1
    return found


def smethods(tree_list):
    """

    :rtype: int
    """
    mlist = list(method for method in tree_list[0][1]
                 .filter(javalang.tree.MethodDeclaration))
    found = 0
    for path, node in mlist:
        if 'static' in node.modifiers:
            found += 1
    return found


def ncss(value_tree):
    """

    :rtype: int
    """
    value = 0
    for path, node in value_tree:
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


if __name__ == '__main__':
    java = sys.argv[1]
    metrics = sys.argv[2]
    with open(java, encoding='utf-8', errors='ignore') as f:
        try:
            raw = javalang.parse.parse(f.read())
            tree = raw.filter(javalang.tree.ClassDeclaration)
            tlist = list(v for v in tree)
            if not tlist:
                raise Exception('This is not a class')
            with open(metrics, 'a') as metric:
                metric.write(f'attributes {attrs(tlist)}: '
                             f'Number of Non-Static Attributes\n')
                metric.write(f'sattributes {sattrs(tlist)}: '
                             f'Number of Static Attributes\n')
                metric.write(f'ctors {ctors(tlist)}: '
                             f'Number of Constructors\n')
                metric.write(f'methods {methods(tlist)}: '
                             f'Number of Non-Static Methods\n')
                metric.write(f'smethods {smethods(tlist)}: '
                             f'Number of Static Methods\n')
                metric.write(f'ncss {ncss(raw)}: '
                             f'Non Commenting Source Statements (NCSS)\n')
        except FileNotFoundError as ex:
            sys.exit(f"{type(ex).__name__} {str(ex)}: {java}")
