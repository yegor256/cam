#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

if tlmgr --version > /dev/null 2>&1; then
  echo -n "$(dirname "$(which tlmgr)")"
  exit
fi

root=/usr/local/texlive
if [ ! -e "${root}" ]; then
  echo "The directory with TeXLive does not exist: ${root}"
  exit 1
fi
year=$(find "${root}/" -maxdepth 1 -type d -name '[0-9][0-9][0-9][0-9]' -exec basename {} \;)
arc=$(find "${root}/${year}/bin/" -maxdepth 1 -type d -name '*-*' -exec basename {} \;)
bin=${root}/${year}/bin/${arc}
if [ ! -e "${bin}" ]; then
  echo "The directory with TeXLive does not exist: ${bin}"
  exit 1
fi
PATH=${bin}:${PATH}
if ! tlmgr --version >/dev/null 2>&1; then
  echo "The directory with TeXLive does exist (${bin}), but 'tlmgr' doesn't run, can't understand why :("
  exit 1
fi

echo -n "${bin}"
