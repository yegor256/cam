#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import sys
from typing import Any, Final

import javalang


def compute_dit(class_decl: Any, all_classes: dict[str, Any]) -> int:
    """Recursively computes the Depth of Inheritance Tree (DIT) for a given class.
    If the class does not explicitly extend any class, it's assumed to extend Object, so DIT = 1.
    If the class extends another class defined in the same file, the DIT is parent's DIT + 1.
    If the parent is not defined in the file, returns 1.
    """
    if class_decl.extends is None:
        return 1
    if (parent_name := getattr(class_decl.extends, "name", "")) in all_classes:
        return compute_dit(all_classes[parent_name], all_classes) + 1
    return 1


def dit_from_tree(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Computes the DIT for the first class in the list tlist."""
    all_classes = {}
    for _, cl in tlist:
        all_classes[cl.name] = cl
    primary = tlist[0][1]
    return compute_dit(primary, all_classes)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python dit.py <path to the .java file> <output file with metrics>"
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
        dit_value = dit_from_tree(tree_class)
        with open(metrics, "a", encoding="utf-8") as m:
            m.write(
                f"DIT {dit_value} Depth of Inheritance Tree: Depth from the class to Object\n"
            )
    except Exception as e:
        sys.exit(f"Error: {str(e)}")
