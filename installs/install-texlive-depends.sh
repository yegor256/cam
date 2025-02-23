#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
