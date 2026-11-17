#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

if pdftotext -v; then
  echo "Poppler is already installed"
  exit
fi


tmp=$(mktemp -d)
mkdir -p "${tmp}"
cd "${tmp}"

wget --quiet https://poppler.freedesktop.org/poppler-data-0.4.12.tar.gz
tar -xf poppler-data-0.4.12.tar.gz
cd poppler-data-0.4.12
make install
cd ..

wget --quiet https://poppler.freedesktop.org/poppler-26.11.0.tar.xz
tar -xf poppler-26.11.0.tar.xz
cd poppler-26.11.0
mkdir build
cd build
# Build the command-line tools without optional API and signing dependencies.
cmake .. \
  -DENABLE_UTILS=ON \
  -DENABLE_CPP=OFF \
  -DENABLE_GLIB=OFF \
  -DENABLE_QT5=OFF \
  -DENABLE_QT6=OFF \
  -DBUILD_MANUAL_TESTS=OFF \
  -DENABLE_BOOST=OFF \
  -DENABLE_NSS3=OFF \
  -DENABLE_GPGME=OFF \
  -DENABLE_LIBCURL=OFF \
  -DENABLE_LIBTIFF=OFF \
  -DENABLE_BROTLI=OFF \
  -DENABLE_HARFBUZZ=OFF \
  -DENABLE_LCMS=OFF

make
make install
ldconfig
