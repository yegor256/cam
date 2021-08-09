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

"""Number of Committers/Authors"""

import sys
from typing import List
from subprocess import Popen, PIPE


def noca(path: str) -> int:
    """
    calculate number of Committers/Authors
    :param path path to java file
    :rtype: int
    :return number of Committers/Authors
    """
    cd_comm: str = f"cd {'/'.join(path.split('/')[:-1])}"
    log_comm: str = f"git log --pretty=format:'%an%x09' {path} | sort | uniq"

    with Popen(
            f"({cd_comm} && {log_comm})",
            shell=True,
            stdout=PIPE,
            stderr=PIPE,
            universal_newlines=True
    ) as process:
        output, errors = process.communicate()
        del errors

    authors: List[str] = output.split()
    return len(authors)


if __name__ == '__main__':
    java: str = sys.argv[1]
    metrics: str = sys.argv[2]

    try:
        with open(metrics, 'a', encoding='utf-8') as metric:
            metric.write(f'authors {noca(java)}: '
                         f'Number of Committers/Authors\n')
    except FileNotFoundError as exception:
        message: str = f"{type(exception).__name__} {str(exception)}: {java}"
        sys.exit(message)
