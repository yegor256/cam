#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import sys
import os
from typing import Final
import chardet

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python delete-wrong-encoding.py <path to the .java file> <output file with .java files>")
        sys.exit(1)

    java: Final[str] = sys.argv[1]
    lst: Final[str] = sys.argv[2]

    try:
        with open(java, 'rb') as f:
            rawdata = f.read()
            result = chardet.detect(rawdata)
            encoding = result['encoding']
            confidence = result['confidence']

        if not (encoding in ('ascii', 'UTF-8') and 1.0 - confidence < 0.01):
            os.remove(java)
            with open(lst, 'a+', encoding='utf-8') as others:
                others.write(java + "\n")

    except Exception:
        pass
