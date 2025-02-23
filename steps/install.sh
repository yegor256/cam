#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT


LINUX_ONLY_PACKAGES=(
  "coreutils"
  "xpdf"
  "libxml2-utils"
)

MACOS_ONLY_PACKAGES=(
  "gnu-sed"
  "wget"
  "poppler"
  "libxml2"
)

PACKAGES_BOTH=(
  "pmd"
  "jpeek"
  "texlive"
  "coreutils"
  "parallel"
  "bc"
  "cloc"
  "jq"
  "shellcheck"
  "aspell"
  "xmlstarlet"
  "gawk"
  "inkscape"
)

if [[ -z "$FORCE_INSTALL" ]]; then
  echo "The following packages will be installed:"

  if "${LOCAL}/help/is-linux.sh"; then
    PACKAGES=("${LINUX_ONLY_PACKAGES[@]}" "${PACKAGES_BOTH[@]}")
  else
    PACKAGES=("${MACOS_ONLY_PACKAGES[@]}" "${PACKAGES_BOTH[@]}")
  fi

  for i in "${PACKAGES[@]}"; do
    echo "  - ${i}"
  done

  read -p "Do you want to proceed with the installation? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Installation aborted by user."
      exit 1
  fi
fi

set -e
set -o pipefail

set -x

if "${LOCAL}/help/is-linux.sh"; then
  "${LOCAL}/help/sudo.sh" apt-get update -y --fix-missing
  "${LOCAL}/help/sudo.sh" apt-get install --yes coreutils
fi

install_package() {
    local PACKAGE=$1
    if ! eval "$PACKAGE" --version >/dev/null 2>&1; then
        if "${LOCAL}/help/is-linux.sh"; then
            "${LOCAL}/help/sudo.sh" apt-get install --yes "$PACKAGE"
        elif "${LOCAL}/help/is-macos.sh"; then
            if brew -v; then
                "${LOCAL}/help/sudo.sh" --as-user brew install "$PACKAGE"
            else
                echo "If you install Homebrew, all necessary packages will be installed automatically by running 'make install'. Visit the Homebrew installation documentation at: https://docs.brew.sh/Installation"
                exit 1
            fi
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

if "${LOCAL}/help/is-macos.sh"; then
  "${LOCAL}/help/sudo.sh" --as-user brew install coreutils
  "${LOCAL}/help/sudo.sh" --as-user brew install gnu-sed
  "${LOCAL}/help/sudo.sh" --as-user brew install wget
fi

if ! pdftotext -v >/dev/null 2>&1; then
  if "${LOCAL}/help/is-linux.sh"; then
    "${LOCAL}/help/sudo.sh" apt-get install --yes xpdf
  elif "${LOCAL}/help/is-macos.sh"; then
    "${LOCAL}/help/sudo.sh" --as-user brew install poppler
  else
    "${LOCAL}/help/assert-tool.sh" pdftotext -v
  fi
fi

if ! inkscape --version >/dev/null 2>&1; then
  if "${LOCAL}/help/is-linux.sh"; then
    "${LOCAL}/help/sudo.sh" add-apt-repository -y ppa:inkscape.dev/stable && \
      "${LOCAL}/help/sudo.sh" apt-get update -y --fix-missing && \
      "${LOCAL}/help/sudo.sh" apt-get install --yes inkscape
  elif "${LOCAL}/help/is-macos.sh"; then
   "${LOCAL}/help/sudo.sh" --as-user brew install --cask inkscape
  else
    "${LOCAL}/help/assert-tool.sh" inkscape --version
  fi
fi

if ! xmllint --version >/dev/null 2>&1; then
  if "${LOCAL}/help/is-linux.sh"; then
    "${LOCAL}/help/sudo.sh" apt-get install --yes libxml2-utils
  elif "${LOCAL}/help/is-macos.sh"; then
    "${LOCAL}/help/sudo.sh" --as-user brew install libxml2
  else
    "${LOCAL}/help/assert-tool.sh" xmllint --version
  fi
fi

find "${LOCAL}/installs" -name 'install-*' | sort | while IFS= read -r i; do
  "${i}"
done

set +x
echo "All dependencies are installed and up to date! Now you can run 'make' and build the dataset."
