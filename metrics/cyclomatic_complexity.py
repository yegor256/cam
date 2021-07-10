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


"""Module's name is cyclomatic_complexity"""

import sys

from javalang import tree, parse


def branches(class_value):
    """
    Determines the number of branches for a node
    according to the Extended Cyclomatic Complexity metric.
    Binary operations (&&, ||) and each case statement
    are taken into account.
    :param class_value: class provided by the parser (targeted to Java 8 spec)
    :returns: number
    :rtype: int
    """
    count = 0
    if isinstance(class_value, tree.BinaryOperation):
        if class_value.operator == '&&' or class_value.operator == '||':
            count = 1
    elif (isinstance(class_value, (
            tree.ForStatement,
            tree.IfStatement,
            tree.WhileStatement,
            tree.DoStatement,
            tree.TernaryExpression
    ))):
        count = 1
    elif isinstance(class_value, tree.SwitchStatementCase):
        count = 1
        # count = len(node.case)
    elif isinstance(class_value, tree.TryStatement):
        count = 1
        # count = len(node.catches)
    return count


if __name__ == '__main__':
    java = sys.argv[1]
    metrics = sys.argv[2]
    with open(java, encoding='utf-8', errors='ignore') as file:
        try:
            complexity: int = 1
            ast = parse.parse(file.read())
            for path, node in ast:
                complexity += branches(node)
            with open(metrics, 'a') as metric:
                metric.write(f'cc {complexity}: Cyclomatic Complexity\n')
        except FileNotFoundError as ex:
            sys.exit(f"{type(ex).__name__} {str(ex)}: {java}")
