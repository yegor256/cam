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

echo "interface Foo {}" > "${temp}/Foo.java"
"${LOCAL}/filters/delete-non-classes.py" "${temp}/Foo.java" "${temp}/deleted.txt"
test ! -e "${temp}/Foo.java"
grep "${temp}/Foo.java" "${temp}/deleted.txt" >/dev/null
echo "👍🏻 A Java file with an interface inside was deleted correctly"

echo "enum Bar {}" > "${temp}/Bar.java"
"${LOCAL}/filters/delete-non-classes.py" "${temp}/Bar.java" "${temp}/deleted.txt"
test ! -e "${temp}/Bar.java"
grep "${temp}/Bar.java" "${temp}/deleted.txt" >/dev/null
echo "👍🏻 A Java file with a enum inside was deleted correctly"

"${LOCAL}/filters/delete-non-classes.py" "${temp}/file-is-absent.java" "${temp}/deleted.txt"
grep -v "${temp}/file-is-absent.java" "${temp}/deleted.txt" >/dev/null
echo "👍🏻 Absent file didn't fail the script"
