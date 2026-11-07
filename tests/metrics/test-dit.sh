#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

temp=$1
stdout=$2

python3 - "${LOCAL}/metrics/dit.py" "${temp}" > "${stdout}" 2>&1 <<'PYTHON'
import pathlib
import runpy
import subprocess
import sys

script = sys.argv[1]
base = pathlib.Path(sys.argv[2])


def check(name, sources, expected, target="Child.java"):
    root = base / name
    root.mkdir()
    for filename, source in sources.items():
        path = root / filename
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(source, encoding="utf-8")
    output = root / "metrics.txt"
    output.write_text("Other 7 Existing metric\n", encoding="utf-8")
    result = subprocess.run(
        [sys.executable, script, str(root / target), str(output), str(root)],
        capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, (name, result.stderr, result.stdout)
    lines = output.read_text(encoding="utf-8").splitlines()
    assert lines[0] == "Other 7 Existing metric", (name, lines)
    assert len(lines) == 2 and lines[1].startswith(f"DIT {expected} "), (name, lines)
    print(name, lines[1])


check("same-file", {"Child.java": "class Child extends Parent {} class Parent {}"}, 2)
check("same-package", {
    "odd/a/Child.java": "package p; class Child extends Parent {}",
    "elsewhere/Parent.java": "package p; class Parent extends Base {}",
    "Base.java": "package p; class Base {}",
}, 3, "odd/a/Child.java")
check("default-package", {
    "Child.java": "class Child extends Parent {}",
    "other/Parent.java": "class Parent {}",
}, 2)
check("import", {
    "Child.java": "package a; import b.Parent; class Child extends Parent {}",
    "Parent.java": "package b; class Parent extends Base {}",
    "Base.java": "package b; class Base {}",
    "Wrong.java": "package c; class Parent {}",
}, 3)
check("qualified", {
    "Child.java": "package a; class Child extends b.Parent<String> {}",
    "Parent.java": "package b; class Parent<T> extends Base {}",
    "Base.java": "package b; class Base {}",
}, 3)
check("wildcard", {
    "Child.java": "package a; import b.*; class Child extends Parent {}",
    "Parent.java": "package b; class Parent {}",
}, 2)
check("nested", {
    "Child.java": "package a; class Child extends b.One.Parent {}",
    "One.java": "package b; class One { static class Parent extends Base {} }",
    "Two.java": "package b; class Two { static class Parent {} }",
    "Base.java": "package b; class Base {}",
}, 3)
check("imported-nested", {
    "Child.java": "package a; import b.One; class Child extends One.Parent {}",
    "One.java": "package b; class One { static class Parent extends Base {} }",
    "Base.java": "package b; class Base {}",
}, 3)
check("lexical", {
    "Child.java": "package a; class Child extends One.Nested {}",
    "One.java": "package a; class One { static class Parent extends Base {} static class Nested extends Parent {} }",
    "Base.java": "package a; class Base {}",
    "Other.java": "package a; class Other { static class Parent {} }",
}, 4)
check("wildcard-nested", {
    "Child.java": "package a; import b.*; class Child extends One.Parent {}",
    "One.java": "package b; class One { static class Parent extends Base {} }",
    "Base.java": "package b; class Base {}",
}, 3)
check("static-nested", {
    "Child.java": "package a; import static b.One.Parent; class Child extends Parent {}",
    "One.java": "package b; class One { static class Parent extends Base {} }",
    "Base.java": "package b; class Base {}",
}, 3)
check("default-shadow", {
    "Child.java": "package p; class Child extends Parent {}",
    "Parent.java": "class Parent extends Base {}",
    "Base.java": "class Base {}",
}, 2)
check("external", {"Child.java": "import missing.Parent; class Child extends Parent {}"}, 2)
check("external-shadow", {
    "Child.java": "package a; import missing.Parent; class Child extends Parent {}",
    "Parent.java": "package a; class Parent extends Base {}",
    "Base.java": "package a; class Base {}",
}, 2)
check("external-chain", {
    "Child.java": "class Child extends Parent {}",
    "Parent.java": "class Parent extends missing.Base {}",
}, 3)
check("object", {"Child.java": "class Child extends java.lang.Object {}"}, 1)
check("implicit-object", {"Child.java": "class Child {}"}, 1)
check("object-name", {
    "Child.java": "package p; class Child extends Object {}",
    "Object.java": "package p; class Object extends Base {}",
    "Base.java": "package p; class Base {}",
}, 3)
module = runpy.run_path(script)
assert module["source_root"](pathlib.Path(script)) == pathlib.Path(script).resolve().parent.parent

for name, sources, message in [
    ("cycle", {"Child.java": "class Child extends Parent {} class Parent extends Child {}"}, "cycle"),
    ("duplicate", {"Child.java": "class Child {}", "Other.java": "class Child {}"}, "Ambiguous source class"),
    ("ambiguous", {
        "Child.java": "import a.*; import b.*; class Child extends Parent {}",
        "A.java": "package a; class Parent {}",
        "B.java": "package b; class Parent {}",
    }, "Ambiguous superclass"),
    ("invalid", {"Child.java": "not valid Java"}, "Error:"),
    ("no-class", {"Child.java": "interface Child {}"}, "top-level class"),
]:
    root = base / name
    root.mkdir()
    for filename, source in sources.items():
        (root / filename).write_text(source, encoding="utf-8")
    output = root / "metrics.txt"
    output.write_text("Other 7 Existing metric\n", encoding="utf-8")
    result = subprocess.run(
        [sys.executable, script, str(root / "Child.java"), str(output), str(root)],
        capture_output=True, text=True, check=False,
    )
    assert result.returncode != 0 and message in result.stderr, (name, result)
    assert output.read_text(encoding="utf-8") == "Other 7 Existing metric\n", name
    print(name, result.stderr.strip())
PYTHON

echo "Depth of Inheritance Tree regression cases passed"
