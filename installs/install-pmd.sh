#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

if [ -z "${LOCAL}" ]; then
  LOCAL=$(dirname "$0")/..
fi

"${LOCAL}/help/assert-tool.sh" javac --version

if pmd --version >/dev/null 2>&1; then
  pmd --version
  echo "PMD is already installed"
  exit
fi

if [ ! -e /usr/local ]; then
  echo "The directory /usr/local must exist"
  exit 1
fi

pmd_version=7.5.0
cd /usr/local || exit 1
name=pmd-dist-${pmd_version}-bin
wget --quiet "https://github.com/pmd/pmd/releases/download/pmd_releases%2F${pmd_version}/${name}.zip"
unzip -qq "${name}.zip"
rm "${name}.zip"
mv "pmd-bin-${pmd_version}" pmd
ln -s /usr/local/pmd/bin/pmd /usr/local/bin/pmd
echo "PMD installed into /usr/local/bin/pmd"
