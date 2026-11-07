#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex
set -o pipefail

if ! "${LOCAL}/help/texlive-bin.sh"; then
  if [ ! -f "install-tl.zip" ]; then
    wget --quiet https://ftp.snt.utwente.nl/pub/software/tex/systems/texlive/tlnet/install-tl.zip
  fi
  rm -rf install-tl
  unzip install-tl.zip -d install-tl
  name=$(find install-tl/ -type d -name "install-tl-*" -exec basename {} \;)
  perl "./install-tl/${name}/install-tl" --scheme=scheme-minimal --no-interaction --repository=https://ftp.snt.utwente.nl/pub/software/tex/systems/texlive/tlnet
  rm -rf install-tl install-tl.zip
fi

if ! tlmgr --version >/dev/null 2>&1; then
  if "${LOCAL}/help/is-linux.sh" || "${LOCAL}/help/is-macos.sh"; then
    PATH=$PATH:$("${LOCAL}/help/texlive-bin.sh")
    export PATH
  else
    "${LOCAL}/help/assert-tool.sh" tlmgr --version
  fi
fi

"${LOCAL}/help/sudo.sh" tlmgr install collection-latex
pdflatex -v
