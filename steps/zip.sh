#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2023 Yegor Bugayenko
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

start=$(date +%s%N)

name=cam-$(date +%Y-%m-%d)

zip=${TARGET}/temp/${name}.zip
mkdir -p "$(dirname "${zip}")"

if [ -e "${zip}" ]; then
    echo "Zip archive already exists: ${zip}"
    exit
fi

if [ -e "${TARGET}/github" ]; then
    echo "Deleting .git directories (may take some time) ..."
    find "${TARGET}/github" -maxdepth 3 -mindepth 3 -type d -name '.git' -exec rm -rf {} \;
fi

echo "Archiving the data into ${zip} (may take some time) ..."
cd "${TARGET}"
zip -qq -x "temp/*" -x "measurements/*" -r "${zip}" .

mv "${zip}" "${TARGET}"

echo "ZIP archive created at ${zip} ($(du -k "${TARGET}/${name}.zip" | cut -f1) Kb)$("${LOCAL}/help/tdiff.sh" "${start}")"
