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

set -x

if "${LOCAL}/help/is-linux.sh"; then
  "${LOCAL}/help/sudo.sh" apt-get update -y --fix-missing
  "${LOCAL}/help/sudo.sh" apt-get install -y coreutils
fi

function install_package() {
    local PACKAGE=$1
    if ! eval "$PACKAGE" --version >/dev/null 2>&1; then
        if "${LOCAL}/help/is-linux.sh"; then
            "${LOCAL}/help/sudo.sh" apt-get install -y "$PACKAGE"
        else
          "${LOCAL}/help/assert-tool.sh" "${PACKAGE}" --version
        fi
    fi
}

install_package parallel
install_package bc
install_package cloc
install_package jq
install_package shellcheck
install_package aspell
install_package xmlstarlet
install_package gawk

if ! pdftotext -v >/dev/null 2>&1; then
  if "${LOCAL}/help/is-linux.sh"; then
    "${LOCAL}/help/sudo.sh" apt-get install -y xpdf
  else
    "${LOCAL}/help/assert-tool.sh" pdftotext -v
  fi
fi

if ! inkscape --version >/dev/null 2>&1; then
  if "${LOCAL}/help/is-linux.sh"; then
    "${LOCAL}/help/sudo.sh" add-apt-repository -y ppa:inkscape.dev/stable && \
      "${LOCAL}/help/sudo.sh" apt-get update -y --fix-missing && \
      "${LOCAL}/help/sudo.sh" apt-get install -y inkscape
  else
    "${LOCAL}/help/assert-tool.sh" inkscape --version
  fi
fi

find "${LOCAL}/installs" -name 'install-*' | sort | while IFS= read -r i; do
  "${i}"
done

set +x
echo "All dependencies are installed and up to date! Now you can run 'make' and build the dataset."
