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

import sys
from collections import defaultdict
from typing import Any
from pydriller import Repository


def list_files(repository: str) -> defaultdict:
    """
    getting all files and all committers relative to each one
    :var repository repository link
    :rtype: defaultdict
    :return: dictionary from filename and its committers
    """
    data: defaultdict[Any, list] = defaultdict(list)
    for commit in Repository(repository).traverse_commits():
        for file in commit.modified_files:
            data[file.filename].append(commit.author.name)
    return data


def unique_authors(dict_files: defaultdict, extension: str = ".java") -> dict:
    """
    creating a unique list of committers for each file with selected extension
    :var dict_files dictionary from filename and its committers
    :var extension filename extension
    :rtype: dict
    :return: dictionary from filename and its committers (no repetitions)
    """
    data: defaultdict[Any, set] = defaultdict(set)
    for file, author in dict_files.items():
        data[file] = set(author)

    data: dict = {
        file: author for file, author in data.items()
        if extension in file
    }
    return data


def metric(dict_files: dict, classname: str) -> str:
    """
    calculating number of committers for a file
    :var dict_files dictionary from filename and its committers
    :var classname name of class for which metric is calculated
    :rtype: str
    :return number of committers for a metric
    """
    for name, author in dict_files.items():
        if classname == name:
            return f"authors {len(author)} Number of Committers/Authors"


if __name__ == '__main__':
    url: str = "https://github.com/cqfn/eo"
    java: str = sys.argv[1]
    metrics: str = sys.argv[2]

    raw_files: defaultdict = list_files(
        repository=url
    )
    files: dict = unique_authors(
        dict_files=raw_files,
        extension=".java"
    )
    noc: str = metric(
        dict_files=files,
        classname=java
    )
    print(noc)
