#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import subprocess
import sys
from pathlib import Path
from typing import Any

import javalang


def source_root(java: Path) -> Path:
    """Find the repository without making assumptions about package directories."""
    result = subprocess.run(
        ["git", "-C", str(java.parent), "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, check=False,
    )
    if result.returncode:
        raise ValueError("Outside a Git repository: supply the source root as the third argument")
    return Path(result.stdout.strip()).resolve()


def package_name(unit: Any) -> str:
    """Read the optional package from javalang's dynamic compilation unit."""
    package = getattr(unit, "package")
    return str(package.name) if package else ""


def collect_classes(declarations: list[Any], prefix: str, unit: Any,
                    classes: dict[str, tuple[Any, Any]]) -> None:
    """Record member types without mixing in method-local class declarations."""
    for declaration in declarations:
        if not isinstance(declaration, javalang.tree.TypeDeclaration):
            continue
        name = f"{prefix}.{declaration.name}" if prefix else declaration.name
        if isinstance(declaration, javalang.tree.ClassDeclaration):
            if name in classes:
                raise ValueError(f"Ambiguous source class: {name}")
            classes[name] = (declaration, unit)
        body = declaration.body
        if isinstance(body, javalang.tree.EnumBody):
            body = body.declarations
        if isinstance(body, list):
            collect_classes(body, name, unit, classes)


def index_classes(root: Path) -> dict[str, tuple[Any, Any]]:
    """Index top-level and member classes by package and enclosing type names."""
    classes: dict[str, tuple[Any, Any]] = {}
    for java in sorted(root.rglob("*.java")):
        if java.is_symlink() or ".git" in java.relative_to(root).parts:
            continue
        try:
            unit: Any = javalang.parse.parse(java.read_text(encoding="utf-8"))
        except (javalang.parser.JavaSyntaxError, javalang.tokenizer.LexerError, UnicodeError) as error:
            raise ValueError(f"Cannot parse source file: {java}") from error
        collect_classes(getattr(unit, "types"), package_name(unit), unit, classes)
    return classes


def reference_name(reference: Any) -> str:
    """Keep the complete name, including qualified and generic member types."""
    suffix = f".{reference_name(reference.sub_type)}" if reference.sub_type else ""
    return str(reference.name) + suffix


def lexical_parent(parent: str, name: str, package: str,
                   classes: dict[str, tuple[Any, Any]]) -> str | None:
    """Look in the current type and enclosing types before consulting imports."""
    scope = name.split(".")
    boundary = len(package.split(".")) if package else 0
    for size in range(len(scope), boundary, -1):
        if (candidate := ".".join([*scope[:size], parent])) in classes:
            return candidate
    return None


def parent_class(name: str, classes: dict[str, tuple[Any, Any]]) -> str | None:
    """Resolve a superclass using lexical scope, explicit imports and packages."""
    declaration, unit = classes[name]
    parent = reference_name(declaration.extends)
    package = package_name(unit)
    if (lexical := lexical_parent(parent, name, package, classes)) is not None:
        return lexical
    first, _, tail = parent.partition(".")
    for imported in unit.imports:
        if not imported.wildcard and imported.path.split(".")[-1] == first:
            return str(imported.path) + (f".{tail}" if tail else "")
    if (candidate := f"{package}.{parent}" if package else parent) in classes:
        return candidate
    if "." in parent and parent in classes:
        return parent
    packages = ["java.lang", *(item.path for item in unit.imports if item.wildcard)]
    candidates = {f"{prefix}.{parent}" for prefix in packages if f"{prefix}.{parent}" in classes}
    if parent == "Object":
        candidates.add("java.lang.Object")
    if len(candidates) > 1:
        raise ValueError(f"Ambiguous superclass {parent} of {name}")
    return next(iter(candidates), parent if "." in parent else None)


def compute_dit(name: str, classes: dict[str, tuple[Any, Any]]) -> int:
    """Count source inheritance edges; unavailable parents give a lower bound.

    A class without extends has depth 1. An unresolved parent contributes one
    additional edge (depth at least 2). Explicit java.lang.Object has depth 1.
    Library bytecode is not inspected, so this is not full classpath DIT.
    """
    depth = 1
    visited: set[str] = set()
    for _ in range(len(classes) + 1):
        if name not in classes:
            break
        if name in visited:
            raise ValueError(f"Inheritance cycle involving {name}")
        visited.add(name)
        declaration, _ = classes[name]
        if declaration.extends is None:
            break
        if (parent := parent_class(name, classes)) == "java.lang.Object":
            break
        depth += 1
        if parent is None:
            break
        name = parent
    return depth


def measure(java: Path, root: Path) -> int:
    """Measure the first top-level class in the target source file."""
    if not root.is_dir() or not java.is_relative_to(root):
        raise ValueError("The source root must be a directory containing the target file")
    unit: Any = javalang.parse.parse(java.read_text(encoding="utf-8"))
    primary = next((item for item in getattr(unit, "types")
                    if isinstance(item, javalang.tree.ClassDeclaration)), None)
    if primary is None:
        raise ValueError("The file does not contain a top-level class declaration")
    package = package_name(unit)
    name = f"{package}.{primary.name}" if package else primary.name
    classes = index_classes(root)
    if name not in classes:
        raise ValueError("The target class was not indexed")
    return compute_dit(name, classes)


if __name__ == "__main__":
    if len(sys.argv) not in (3, 4):
        sys.exit("Usage: dit.py <Java file> <metrics file> [source root]")
    try:
        target = Path(sys.argv[1]).resolve()
        source = Path(sys.argv[3]).resolve() if len(sys.argv) == 4 else source_root(target)
        value = measure(target, source)
        with open(sys.argv[2], "a", encoding="utf-8") as output:
            output.write(f"DIT {value} Source inheritance depth (lower bound for unavailable parents)\n")
    except (OSError, ValueError, javalang.parser.JavaSyntaxError, javalang.tokenizer.LexerError) as error:
        sys.exit(f"Error: {error}")
