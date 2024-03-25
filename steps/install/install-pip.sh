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

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  linux=yes
fi
set -x

if [ -n "${linux}" ]; then
  SUDO=
else
  SUDO=sudo
fi

if [ -n "${linux}" ]; then
  if [ ! "$(id -u)" = 0 ]; then
    echo "You should run it as root: 'sudo make install'"
    exit 1
  fi
fi

if ! python3 --version >/dev/null 2>&1; then
  echo "Install 'python3' somehow"
  exit 1
fi
if ! pip --version >/dev/null 2>&1; then
  echo "Install 'pip' somehow"
  exit 1
fi
$SUDO python3 -m pip install --upgrade pip
$SUDO python3 -m pip install -r "${LOCAL}/requirements.txt"
