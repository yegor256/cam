#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import sys
from typing import Any, Final, List, Set, Tuple

import javalang


def get_class_fields(
    tlist: List[Tuple[Any, javalang.tree.ClassDeclaration]],
) -> Set[str]:
    """Extracts the set of field names declared in the first class."""
    fields = set()
    for _, field_decl in tlist[0][1].filter(javalang.tree.FieldDeclaration):
        for declarator in field_decl.declarators:
            fields.add(declarator.name)
    return fields


def get_method_field_usage(
    method: javalang.tree.MethodDeclaration, class_fields: Set[str]
) -> Set[str]:
    """Returns the set of field names (from class_fields) that are used in the method."""
    used = set()
    if method.body is None:
        return used
    for stmt in method.body:
        for _, node in stmt.filter(javalang.tree.MemberReference):
            if node.member in class_fields:
                used.add(node.member)
    return used


def lcom(tlist: List[Tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Computes the Lack of Cohesion of Methods (LCOM) metric using the LCOM1 definition.

    For each pair of methods in the class, if they do not share any common field, increment P;
    if they share at least one field, increment Q. The metric is defined as:
        LCOM = P - Q  if P > Q, otherwise 0.

    Returns:
      The LCOM value as an integer.
    """
    class_fields = get_class_fields(tlist)

    methods_usage: List[Set[str]] = []
    for _, method in tlist[0][1].filter(javalang.tree.MethodDeclaration):
        used_fields = get_method_field_usage(method, class_fields)
        methods_usage.append(used_fields)

    P = 0
    Q = 0
    n = len(methods_usage)
    for i in range(n):
        for j in range(i + 1, n):
            if methods_usage[i].intersection(methods_usage[j]):
                Q += 1
            else:
                P += 1
    return P - Q if P > Q else 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python lcom.py <path to the .java file> <output file with metrics>"
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
        lcom_value = lcom(tree_class)
        with open(metrics, "a", encoding="utf-8") as m:
            m.write(f"LCOM {lcom_value} Lack of Cohesion of Methods (LCOM1)\n")
    except Exception as e:
        sys.exit(f"Error: {str(e)}")
