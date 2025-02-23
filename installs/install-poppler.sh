#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
