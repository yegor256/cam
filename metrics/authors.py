#!/usr/bin/env python
# The MIT License (MIT)
#
# Copyright (c) 2021 Yegor Bugayenko
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

from collections import defaultdict
from typing import Any
from pydriller import Repository

if __name__ == '__main__':
    path: str = 'https://github.com/cqfn/eo'
    raw_files: defaultdict[Any, list] = defaultdict(list)
    for commit in Repository(path).traverse_commits():
        for file in commit.modified_files:
            raw_files[file.filename].append(commit.author.name)

    files: defaultdict[Any, set] = defaultdict(set)
    for name, author in raw_files.items():
        files[name] = set(author)

    # <editor-fold desc="test for TypeTest.java">
    type_test = files['TypeTest.java']
    print(f"List of authors: {type_test}")
    print(f"Number of authors: {len(type_test)}")
    # </editor-fold>
