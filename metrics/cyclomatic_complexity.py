#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import sys
from typing import Final
from javalang import tree, parse

sys.setrecursionlimit(10000)


def branches(parser_class: tree.CompilationUnit) -> int:
    """Determines the number of branches for a node
    according to the Extended Cyclomatic Complexity metric.
    Binary operations (&&, ||) and each case statement
    are taken into account.
    """
    count = 0
    if isinstance(parser_class, tree.BinaryOperation):
        if parser_class.operator in ('&&', '||'):
            count = 1
    elif isinstance(
        parser_class,
        (
            tree.ForStatement,
            tree.IfStatement,
            tree.WhileStatement,
            tree.DoStatement,
            tree.TernaryExpression
        )
    ):
        count = 1
    elif isinstance(parser_class, tree.SwitchStatementCase):
        count = 1
    elif isinstance(parser_class, tree.TryStatement):
        count = 1
    return count


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python cyclomatic_complexity.py <path to the .java file> <output file with metrics>")
        sys.exit(1)

    java: Final[str] = sys.argv[1]
    metrics: Final[str] = sys.argv[2]
    with open(java, encoding='utf-8', errors='ignore') as f:
        try:
            complexity: int = 1
            ast = parse.parse(f.read())
            for path, node in ast:
                complexity += branches(node)
            with open(metrics, 'a', encoding='utf-8') as m:
                m.write(f'CC {complexity} Total \
                    Cyclomatic Complexity~\\citep{{mccabe1976complexity}} \
                    of all methods\n')
        except FileNotFoundError as exception:
            message = f"{type(exception).__name__} {str(exception)}: {java}"
            sys.exit(message)
