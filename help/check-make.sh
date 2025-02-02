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

make_version=$(make --version | awk 'NR==1 {print $3}')
make_version_int=$(echo "${make_version}" | cut -d'.' -f1)

if [ "${make_version_int}" -lt 4 ]; then
    echo "Make version must be 4 or higher. Current: ${make_version}"
    if "${LOCAL}/help/is-macos.sh" ; then
        echo "Try to update it with \"brew install make\""
        if [ "$(uname -m)" = "arm64" ]; then
            echo "Make sure you have \"/opt/homebrew/opt/make/libexec/gnubin\" in your PATH"
        else
            echo "Make sure you have \"/usr/local/opt/make/libexec/gnubin\" in your PATH"
        fi
    else
        echo "Try to update it with \"sudo apt install make\""
    fi
    exit 1
fi
