#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2025 Yegor Bugayenko
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
    repo="yegor256/jaxec"
    echo -e "name\n${repo}" > "${TARGET}/repositories.csv"
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/github/${repo}"
    cp -r "${LOCAL}/fixtures/jaxec"/* "${TARGET}/github/${repo}"
    msg=$("${LOCAL}/steps/jpeek.sh")
    echo "${msg}"
    echo "${msg}" | grep "Analyzed ${repo} through jPeek"
    mfile=${TARGET}/measurements/${repo}/src/main/java/com/yegor256/Jaxec.java.m.NHD
    value=$(cat "${mfile}")
    test ! "${value}" = '0'
    test ! "${value}" = 'NaN'
} > "${stdout}" 2>&1
echo "👍🏻 A simple repo analyzed with jpeek correctly"
