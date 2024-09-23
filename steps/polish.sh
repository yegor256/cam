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

dir=${TARGET}/github
if [ ! -e "${dir}" ]; then
    echo "Nothing to polish, the directory is absent: ${dir}"
    exit
fi

rlist=${TARGET}/temp/repos-to-polish.txt
mkdir -p "$(dirname "${rlist}")"
echo "Wait a bit, searching for repos in '${dir}'..."
find "${dir}" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'realpath --relative-to="${1}" "$2"' _ "${dir}" {} \; > "${rlist}"

if [ -s "${rlist}" ]; then
    declare -i rtotal=0
    while IFS= read -r repo; do
        if grep "${repo}," "${TARGET}/repositories.csv"; then
            echo "Directory of ${repo} is already here"
        else
            rm -rf "${dir:?}/${repo}"
            echo "Directory of ${repo} is obsolete and was deleted"
        fi
        rtotal=$((rtotal+1))
    done < "${rlist}"
    echo "All ${rtotal} repo directories inside ${dir} were checked"
else
    echo "No repo directories inside ${dir}"
    exit
fi

olist=${TARGET}/temp/orgs-to-polish.txt
mkdir -p "$(dirname "${olist}")"
echo "Wait a bit, searching for orgs in '${dir}'..."
 
find "${dir}" -maxdepth 1 -mindepth 1 -type d -exec bash -c 'realpath --relative-to="${1}" "$2"' _ "${dir}" {} \; > "${olist}"

if [ -s "${olist}" ]; then
    declare -i ototal=0
    while IFS= read -r org; do
        if [ "$(find "${dir}/${org}" -type d | wc -l | xargs)" == '0' ]; then
            rm -rf "${dir:?}/${org}"
            echo "Organization ${org} is empty and was deleted"
        fi
        ototal=$((ototal+1))
    done < "${olist}"
    echo "All ${ototal} org directories inside ${dir} were checked"
else
    echo "No org directories inside ${dir}"
    exit
fi
