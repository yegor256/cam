#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

temp=$(mktemp -d)
trap 'rm -r "${temp}"' EXIT
stdout=$2

{
    mkdir -p "${temp}/checkout"
    export GIT_INDEX_FILE="${temp}/index"
    git -C "${LOCAL}" read-tree HEAD
    git -C "${LOCAL}" -c core.autocrlf=true -c core.eol=crlf \
        checkout-index --all --prefix="${temp}/checkout/"
    for file in Makefile Dockerfile DEPENDS.txt steps/discover-repos.rb \
        installs/install-texlive-depends.sh metrics/ast.py; do
        if LC_ALL=C grep -q $'\r' "${temp}/checkout/${file}"; then
            echo "CR found in Windows-style checkout: ${file}"
            exit 1
        fi
    done
} > "${stdout}" 2>&1
