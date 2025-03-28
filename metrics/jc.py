#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import sys
from typing import Any, Final

import javalang


def has_javadoc(lines_list: list[str], method_line: int) -> bool:
    """Check whether a Javadoc comment exists immediately before the method declaration.

    Arguments:
      lines_list: list of lines from the source file.
      method_line: the line number (1-based) where the method declaration starts.

    Returns:
      True if a Javadoc comment is present immediately before the method, otherwise False.
    """
    comment_block = []
    for line in reversed(lines_list[: method_line - 1]):
        if not (stripped_line := line.strip()):
            break
        if (
            stripped_line.startswith("/*")
            or stripped_line.startswith("*")
            or stripped_line.startswith("//")
        ):
            comment_block.append(stripped_line)
        else:
            break
    if comment_block:
        comment_block.reverse()  # Reverse to restore original order.
        return comment_block[0].startswith("/**")
    return False


def javadoc_coverage(
    tlist: list[tuple[Any, javalang.tree.ClassDeclaration]], lines_list: list[str]
) -> float:
    """Calculate the Javadoc coverage, i.e., the ratio of methods documented with Javadoc to total methods in a class.

    :rtype: float
    """
    methods_list = list(
        method for method in tlist[0][1].filter(javalang.tree.MethodDeclaration)
    )
    if not methods_list:
        return 0.0

    documented = 0
    total = 0

    for _, node in methods_list:
        total += 1
        if node.position is not None:
            method_line = node.position[
                0
            ]  # The line number where the method declaration starts.
            if has_javadoc(lines_list, method_line):
                documented += 1
    return documented / total


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python jc.py <path to the .java file> <output file with metrics>"
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
            lines_from_file = raw_text.splitlines()
            coverage = javadoc_coverage(tree_class, lines_from_file)
            coverage = round(coverage, 2)
            with open(metrics, "a", encoding="utf-8") as m:
                m.write(
                    f"JDC {coverage} Javadoc Coverage: Ratio of methods documented with Javadoc to total methods\n"
                )
        except Exception as e:
            sys.exit(f"Error: {str(e)}")
