#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import sys
from typing import Any, Final

import javalang


def get_end_line(obj: Any) -> int:
    """Recursively traverse the given object (AST node or list) and return the maximum line number found.
    If no line number is found, returns 0."""
    max_line = 0
    if hasattr(obj, "position") and obj.position is not None:
        max_line = obj.position[0]
    if isinstance(obj, list):
        for item in obj:
            if (candidate := get_end_line(item)) > max_line:
                max_line = candidate
    elif hasattr(obj, "__dict__"):
        for value in obj.__dict__.values():
            if (candidate := get_end_line(value)) > max_line:
                max_line = candidate
    return max_line


def average_method_length(
    tlist: list[tuple[Any, javalang.tree.ClassDeclaration]],
) -> float:
    """Calculate the Average Method Length (AML), defined as the average number of lines per method in a class.
    The method length is estimated as the difference between the method's starting line and the maximum line number
    found in its body.

    :rtype: float"""
    methods = list(
        method for method in tlist[0][1].filter(javalang.tree.MethodDeclaration)
    )
    if not methods:
        return 0.0

    total_length = 0
    count = 0
    for _, method in methods:
        if method.position is None:
            continue
        start_line = method.position[0]
        end_line = get_end_line(method.body) if method.body is not None else start_line
        length = end_line - start_line + 1
        total_length += length
        count += 1
    return total_length / count if count else 0.0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python aml.py <path to the .java file> <output file with metrics>"
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
            aml = average_method_length(tree_class)
            with open(metrics, "a", encoding="utf-8") as m:
                m.write(
                    f"AML {aml} Average Method Length: Average number of lines per method\n"
                )
        except Exception as e:
            sys.exit(f"Error: {str(e)}")
