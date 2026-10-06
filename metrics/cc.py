#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import sys
from typing import Any, Final

import javalang


def compute_cognitive_complexity(node: Any, nesting: int = 0) -> int:
    """Recursively computes the cognitive complexity of an AST node.

    For each control structure (if, for, while, do, ternary, try, catch),
    the function adds 1 plus the current nesting level.
    For each binary operation with '&&' or '||', it adds 1.
    It then recursively computes the complexity for child nodes.

    Args:
        node: The AST node to compute complexity for.
        nesting: The current nesting level (default is 0).

    Returns:
        The computed cognitive complexity as an integer.
    """
    complexity = 0
    # Define control structure types that increase complexity
    control_structures = (
        javalang.tree.IfStatement,
        javalang.tree.ForStatement,
        javalang.tree.WhileStatement,
        javalang.tree.DoStatement,
        javalang.tree.TernaryExpression,
        javalang.tree.TryStatement,
        javalang.tree.CatchClause,
    )

    if isinstance(node, control_structures):
        complexity += 1 + nesting
        new_nesting = nesting + 1
    else:
        new_nesting = nesting

    if isinstance(node, javalang.tree.BinaryOperation) and node.operator in (
        "&&",
        "||",
    ):
        complexity += 1

    # Recursively compute complexity for child nodes.
    for child in node.children:
        if isinstance(child, list):
            for sub in child:
                if isinstance(sub, javalang.tree.Node):
                    complexity += compute_cognitive_complexity(sub, new_nesting)
        elif isinstance(child, javalang.tree.Node):
            complexity += compute_cognitive_complexity(child, new_nesting)
    return complexity


def cognitive_complexity_for_class(
    tlist: list[tuple[Any, javalang.tree.ClassDeclaration]],
) -> int:
    """Calculates the total cognitive complexity for all methods in the first class of the list.

    It iterates over all method declarations in the class, computes the cognitive complexity for each statement
    in the method body, and sums up the values.

    Returns:
        The total cognitive complexity as an integer.
    """
    total_complexity = 0
    methods = list(
        method for method in tlist[0][1].filter(javalang.tree.MethodDeclaration)
    )
    for _, method in methods:
        if method.body is not None:
            for stmt in method.body:
                total_complexity += compute_cognitive_complexity(stmt, 0)
    return total_complexity


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python cognitive_complexity.py <path to the .java file> <output file with metrics>"
        )
        sys.exit(1)

    java: Final[str] = sys.argv[1]
    metrics: Final[str] = sys.argv[2]
    with open(java, encoding="utf-8", errors="ignore") as file:
        raw_text = file.read()
    try:
        parsed = javalang.parse.parse(raw_text)
        if not (tree_class := list(parsed.filter(javalang.tree.ClassDeclaration))):
            raise ValueError("The file does not contain a valid class declaration")
        cc = cognitive_complexity_for_class(tree_class)
        with open(metrics, "a", encoding="utf-8") as m:
            m.write(
                f"CoCo {cc} Cognitive Complexity: Total cognitive complexity of all methods in the class\n"
            )
    except Exception as e:
        sys.exit(f"Error: {str(e)}")
