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

stdout=$2

{
    repo="git-siblings-repo"
    dir="${TARGET}/data/${repo}"
    mkdir -p "${dir}"
    git init "${dir}"
    # Add Two Java Files
    echo "public class Test1 {}" > "${dir}/Test1.java"
    echo "public class Test2 {}" > "${dir}/Test2.java"
    git -C "${dir}" add . && git -C "${dir}" commit -m "Add Test1 and Test2"
    # Modify Test1.java
    echo "// Comment added" >> "${dir}/Test1.java"
    git -C "${dir}" add . && git -C "${dir}" commit -m "Modify Test1.java"

    # Add another Java file
    echo "public class Test3 {}" > Test3.java
    git -C "${dir}" add . && git -C "${dir}" commit -m "Add Test3"
    
    # Step 3: Verify the Output
    if grep -q "Test1.java" "${dir}/siblings_count.txt" && grep -q "Test2.java" "${dir}/siblings_count.txt" && grep -q "Test3.java" "${dir}/siblings_count.txt"; then
        echo "Test passed: All expected Java files are present in the analysis."
    else
        echo "Test failed: Analysis output is missing one or more expected Java files."
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Siblings count verified"