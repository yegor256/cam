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

if ! tlmgr --version >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    PATH=$PATH:$("${LOCAL}/help/texlive-bin.sh")
    export PATH
  else
    echo "Install 'TeXLive' somehow"
    exit 1
  fi
fi

if [ ! -e "${HOME}/texmf" ]; then
  $SUDO tlmgr init-usertree
fi
$SUDO tlmgr option repository ctan
$SUDO tlmgr --verify-repo=none update --self
packages=()
while IFS= read -r p; do
  packages+=( "${p}" )
done < <( cut -d' ' -f2 "${LOCAL}/DEPENDS.txt" | uniq )
$SUDO tlmgr --verify-repo=none install "${packages[@]}"
$SUDO tlmgr --verify-repo=none update --no-auto-remove "${packages[@]}" || echo 'Failed to update'
