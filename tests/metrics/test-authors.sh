#!/usr/bin/env bash
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
set -e
set -o pipefail

temp=$1
stdout=$2

{
    tmp=$(mktemp -d /tmp/XXXX)
    "${LOCAL}/metrics/authors.sh" "${tmp}" "${temp}/stdout"
    grep "NoGA 0 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Didn't fail in non-git directory"

{
    mkdir -p "${temp}/foo"
    cd "${temp}/foo"
    git init --quiet .
    git config user.email 'foo@example.com'
    git config user.name 'Foo'
    java="Foo long 'weird' name (--).java"
    echo "class Foo {}" > "${java}"
    git add "${java}"
    git config commit.gpgsign false
    git commit --quiet -am start
    "${LOCAL}/metrics/authors.sh" "${java}" stdout
    grep "NoGA 1 " stdout
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated authors"
