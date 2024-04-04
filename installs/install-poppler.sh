#!/usr/bin/env bash
# MIT License
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
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e
set -o pipefail

if pdftotext -v; then
  echo "Poppler is already installed"
  exit
fi


tmp=$(mktemp -d)
mkdir -p "${tmp}"
cd "${tmp}"

wget --quiet https://poppler.freedesktop.org/poppler-data-0.4.9.tar.gz
tar -xf poppler-data-0.4.9.tar.gz
cd poppler-data-0.4.9
make install
cd ..

wget --quiet https://poppler.freedesktop.org/poppler-20.08.0.tar.xz
tar -xf poppler-20.08.0.tar.xz
cd poppler-20.08.0
mkdir build
cd build
cmake ..

make
make install
ldconfig
