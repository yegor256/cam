#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import sys
from typing import Any, Final

import javalang


PRIMITIVES = {
    "int",
    "float",
    "double",
    "boolean",
    "char",
    "byte",
    "short",
    "long",
    "void",
}


def get_type_name(typ: Any) -> str:
    """Extracts the name of the type from a javalang type node."""
    if typ is None:
        return ""
    return getattr(typ, "name", "")


def process_fields(class_decl: Any, coupled: set[str]) -> None:
    """Process field declarations to find coupled classes."""
    for _, field_decl in class_decl.filter(javalang.tree.FieldDeclaration):
        if (
            type_name := get_type_name(field_decl.type)
        ) and type_name not in PRIMITIVES:
            coupled.add(type_name)


def process_methods(class_decl: Any, coupled: set[str]) -> None:
    """Process method parameters and return types to find coupled classes."""
    for _, method in class_decl.filter(javalang.tree.MethodDeclaration):
        for param in method.parameters:
            if (
                param_type := get_type_name(param.type)
            ) and param_type not in PRIMITIVES:
                coupled.add(param_type)
        if (
            hasattr(method, "return_type")
            and (ret_type := get_type_name(method.return_type))
            and ret_type not in PRIMITIVES
        ):
            coupled.add(ret_type)


def process_inheritance(class_decl: Any, coupled: set[str]) -> None:
    """Process extends and implements clauses to find coupled classes."""
    if (
        extends_name := get_type_name(class_decl.extends)
    ) and extends_name not in PRIMITIVES:
        coupled.add(extends_name)
    if class_decl.implements:
        for impl in class_decl.implements:
            if (impl_name := get_type_name(impl)) and impl_name not in PRIMITIVES:
                coupled.add(impl_name)


def cbo(tlist: list[tuple[Any, javalang.tree.ClassDeclaration]]) -> int:
    """Computes the Coupling Between Objects (CBO) for the first class in tlist."""
    class_decl = tlist[0][1]
    current_class = class_decl.name
    coupled: set[str] = set()

    process_fields(class_decl, coupled)
    process_methods(class_decl, coupled)
    process_inheritance(class_decl, coupled)

    coupled.discard(current_class)
    return len(coupled)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python cbo.py <path to the .java file> <output file with metrics>"
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

        cbo_value = cbo(tree_class)
        with open(metrics, "a", encoding="utf-8") as m:
            m.write(
                f"CBO {cbo_value} Coupling Between Objects: "
                "Number of distinct external classes referenced by this class\n"
            )
    except Exception as e:
        sys.exit(f"Error: {str(e)}")
