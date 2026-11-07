#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT
"""Convert calculator records to CSV and render the shared metric catalog."""

import csv
import re
import sys


def plain(description: str) -> str:
    """Render the LaTeX constructs used by calculator descriptions as text."""
    description = re.sub(r"\\cite[pt]?\{[^}]*\}", "", description)
    description = re.sub(r"\\href\{[^}]*\}\{([^}]*)\}", r"\1", description)
    description = re.sub(r"\\frac\{([^{}]*)\}\{([^{}]*)\}", r"(\1)/(\2)", description)
    if (unwrapped := re.sub(r"\\[a-zA-Z]+\{([^{}]*)\}", r"\1", description)) != description:
        return plain(unwrapped)
    description = re.sub(r"\\([%_&#$])", r"\1", description)
    for command, symbol in (("times", "*"), ("cdot", "*"), ("log", "log")):
        description = description.replace("\\" + command, symbol)
    description = re.sub(r"\\[a-zA-Z]+", "", description)
    description = re.sub(r"\\[()\[\]]", "", description)
    return " ".join(description.replace("~", " ").split())


def main() -> None:
    """Read raw calculator records or CSV from standard input."""
    if (mode := sys.argv[1]) == "csv":
        writer = csv.writer(sys.stdout, lineterminator="\n")
        for line in sys.stdin:
            fields = line.split(maxsplit=2)
            if len(fields) >= 2:
                writer.writerow([fields[0], fields[2].strip() if len(fields) == 3 else ""])
    else:
        rows = list(csv.reader(sys.stdin))
        for name, description in rows:
            if mode == "tex":
                print(f"\\item\\ff{{{name}}}: {description}")
            else:
                print(f"{name}: {plain(description)}")
        if mode == "text":
            print(f"Total metrics: {len(rows)}")


if __name__ == "__main__":
    main()
