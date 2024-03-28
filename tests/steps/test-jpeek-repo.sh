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
    javac -version
    mvn --version
    gradle --version
    java -jar "${JPEEK}" --help
} > "${stdout}" 2>&1
echo "👍🏻 jPeek dependencies are installed"

{
    repo="yegor256/jaxec"
    echo -e "name\n${repo}" > "${TARGET}/repositories.csv"
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/github/${repo}"
    cp -r "${LOCAL}/fixtures/jaxec"/* "${TARGET}/github/${repo}"
    msg=$("${LOCAL}/steps/jpeek-repo.sh" "${repo}" 1 1)
    test "$(echo "${msg}" | grep -c "0 classes, sum is 0")" = 0
    echo "${msg}" | grep "Analyzed ${repo} through jPeek"
    echo "${msg}" | grep ", 2 classes"
    mfile=${TARGET}/measurements/${repo}/src/main/java/com/yegor256/Jaxec.java.m.NHD
    test -e "${mfile}"
    value=$(cat "${mfile}")
    test ! "${value}" = '0'
    test ! "${value}" = 'NaN'
    test -e "${TARGET}/measurements/${repo}/src/main/java/com/yegor256/Jaxec.java.m.NHD-cvc"
    test ! -e "${TARGET}/measurements/${repo}/src/main/java/com/yegor256/Jaxec.java.m.NHD-cvc-cvc"
} > "${stdout}" 2>&1
echo "👍🏻 A simple repo analyzed with jpeek correctly"

{
    repo="foo/bar"
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/temp/jpeek-logs/${repo}"
    msg=$("${LOCAL}/steps/jpeek-repo.sh" "${repo}" 1 1)
    echo "${msg}" | grep "Repo ${repo} already analyzed by jPeek"
} > "${stdout}" 2>&1
echo "👍🏻 A duplicate analysis didn't happen"
