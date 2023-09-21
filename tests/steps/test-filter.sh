#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
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

rm -rf "${TARGET}/github"
mkdir -p "${TARGET}/github/a/b"
"${LOCAL}/steps/filter.sh" >/dev/null
echo "👍🏻 A simple filtering ran smoothly"

rm -rf "${TARGET}/github"
rm -rf "${TARGET}/temp/reports"
rm -rf "${TARGET}/temp/filter-lists"
mkdir -p "${TARGET}/github/foo/bar"
echo "class Foo {}" > "${TARGET}/github/foo/bar/Foo.java"
echo "interface Boom {}" > "${TARGET}/github/foo/bar/Boom.java"
echo "broken code" > "${TARGET}/github/foo/bar/Broken.java"
"${LOCAL}/steps/filter.sh" >/dev/null
test ! -e "${TARGET}/github/foo/bar/Broken.java"
test ! -e "${TARGET}/github/foo/bar/Boom.java"
echo "👍🏻 A more complex filtering ran smoothly"
