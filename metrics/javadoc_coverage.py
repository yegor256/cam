#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import sys
from typing import Any, Final, List

import javalang


def has_javadoc(lines: List[str], method_line: int) -> bool:
    """
    Checks whether a Javadoc comment exists immediately before the method declaration.
    Arguments:
      lines: list of lines from the source file.
      method_line: the line number (1-based) where the method declaration starts.
    Returns:
      True if a Javadoc comment is present immediately before the method, otherwise False.
    """
    i = (
        method_line - 2
    )  # Move to the line before the method declaration (0-based indexing)
    if i < 0:
        return False

    comment_block = []
    # Collect the comment block that is immediately above the method.
    while i >= 0:
        line = lines[i].strip()
        # If the line is empty, assume a break between the comment and the method.
        if line == "":
            break
        # If the line starts with comment symbols.
        if line.startswith("/*") or line.startswith("*") or line.startswith("//"):
            comment_block.append(line)
            i -= 1
        else:
            break
    # If a comment block is found, check if it starts with "/**".
    if comment_block:
        comment_block.reverse()  # Reverse to get the correct order
        return comment_block[0].startswith("/**")
    return False


def javadoc_coverage(
    tlist: list[tuple[Any, javalang.tree.ClassDeclaration]], lines: List[str]
) -> float:
    """
    Calculates the Javadoc coverage, i.e., the ratio of methods with Javadoc comments
    to the total number of methods in a class.

    :rtype: float
    """
    declaration = tlist[0][1].filter(javalang.tree.MethodDeclaration)
    methods_list = list(method for method in declaration)
    if not methods_list:
        return 0.0

    documented = 0
    total = 0

    for path, node in methods_list:
        total += 1
        if node.position is not None:
            method_line = node.position[
                0
            ]  # The line number where the method declaration starts
            if has_javadoc(lines, method_line):
                documented += 1
    return documented / total


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python javadoc_coverage.py <path to the .java file> <output file with metrics>"
        )
        sys.exit(1)

    java: Final[str] = sys.argv[1]
    metrics: Final[str] = sys.argv[2]
    with open(java, encoding="utf-8", errors="ignore") as file:
        raw_text = file.read()
        try:
            parsed = javalang.parse.parse(raw_text)
            tree_class = list(parsed.filter(javalang.tree.ClassDeclaration))
            if not tree_class:
                raise Exception("This is not a class")
            lines = raw_text.splitlines()
            coverage = javadoc_coverage(tree_class, lines)
            with open(metrics, "a", encoding="utf-8") as m:
                m.write(
                    f"JDC {coverage} Javadoc Coverage: Ratio of methods documented with Javadoc to total methods\n"
                )
        except Exception as e:
            sys.exit(f"Error: {str(e)}")
