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

set -ex
set -o pipefail

if ! tlmgr --version >/dev/null 2>&1; then
  PATH=$PATH:$("${LOCAL}/help/texlive-bin.sh")
  export PATH
fi

if "${LOCAL}/help/is-macos.sh"; then
  if [ ! -e "${HOME}/Library/texmf" ] && [ ! -e "${HOME}/texmf/tlpkg/texlive.tlpdb" ]; then
    "${LOCAL}/help/sudo.sh" tlmgr init-usertree
  fi
elif "${LOCAL}/help/is-linux.sh"; then
  if [ ! -e "${HOME}/texmf" ]; then
    "${LOCAL}/help/sudo.sh" tlmgr init-usertree
  fi
fi
"${LOCAL}/help/sudo.sh" tlmgr option repository http://mirror.ctan.org/systems/texlive/tlnet
"${LOCAL}/help/sudo.sh" tlmgr --verify-repo=none update --self
packages=()
while IFS= read -r p; do
  packages+=( "${p}" )
done < <( cut -d' ' -f2 "${LOCAL}/DEPENDS.txt" | uniq )
"${LOCAL}/help/sudo.sh" tlmgr --verify-repo=none install "${packages[@]}"
"${LOCAL}/help/sudo.sh" tlmgr --verify-repo=none update --no-auto-remove "${packages[@]}" || echo 'Failed to update'
