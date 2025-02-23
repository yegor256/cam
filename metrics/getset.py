#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

# This metric counts the number of getter and setter methods in a class.

import sys
from javalang import tree, parse

sys.setrecursionlimit(10000)


def is_getter_or_setter(method: tree.MethodDeclaration) -> str | None:
    """Figures out whether a method is a getter or a setter."""
    if isinstance(method, tree.MethodDeclaration):
        if method.name.startswith("get") and len(method.parameters) == 0:
            return "getter"
        if method.name.startswith("set") and len(method.parameters) == 1:
            return "setter"
    return None


def analyze_method(method: tree.MethodDeclaration) -> str | None:
    """Analyzes the complexity of the method."""
    if not (method_type := is_getter_or_setter(method)):
        return None

    return method_type


if __name__ == '__main__':
    java = sys.argv[1]
    metrics = sys.argv[2]

    getter_count = 0
    setter_count = 0
    with open(java, encoding='utf-8', errors='ignore') as f:
        try:
            ast = parse.parse(f.read())
            for _, tree_node in ast.filter(tree.MethodDeclaration):
                if (result := analyze_method(tree_node)):
                    method_type_result = result
                    if method_type_result == 'getter':
                        getter_count += 1

                    if method_type_result == 'setter':
                        setter_count += 1

            with open(metrics, 'a', encoding='utf-8') as m:
                m.write(f'Getters {getter_count} The number of getter methods\n')
                m.write(f'Setters {setter_count} The number of setter methods\n')
        except FileNotFoundError as exception:
            message = f"{type(exception).__name__} {str(exception)}: {java}"
            sys.exit(message)
