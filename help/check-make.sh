#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

make_version=$(make --version | awk 'NR==1 {print $3}')
make_version_int=$(echo "${make_version}" | cut -d'.' -f1)

if [ "${make_version_int}" -lt 4 ]; then
    echo "Make version must be 4 or higher. Current: ${make_version}"
    if "${LOCAL}/help/is-macos.sh" ; then
        echo "Try to update it with \"brew install make\""
        if [ "$(uname -m)" = "arm64" ]; then
            echo "Make sure you have \"/opt/homebrew/opt/make/libexec/gnubin\" in your PATH"
        else
            echo "Make sure you have \"/usr/local/opt/make/libexec/gnubin\" in your PATH"
        fi
    else
        echo "Try to update it with \"sudo apt install make\""
    fi
    exit 1
fi
