#!/usr/bin/env python3
# The MIT License (MIT)
#
# Copyright (c) 2021-2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import sys
import os
from typing import Final
import javalang

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python delete-unparseable.py <path to the .java file> <output file with .java files>")
        sys.exit(1)

    java: Final[str] = sys.argv[1]
    lst: Final[str] = sys.argv[2]
    try:
        with open(java, encoding='utf-8') as f:
            try:
                raw = javalang.parse.parse(f.read())
                tree = raw.filter(javalang.tree.ClassDeclaration)
                list((value for value in tree))
            except Exception:
                os.remove(java)
                with open(lst, 'a+', encoding='utf-8') as others:
                    others.write(java + "\n")
    except Exception:
        pass
