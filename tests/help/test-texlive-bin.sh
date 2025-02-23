#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

{
    "${LOCAL}/help/texlive-bin.sh"
    path=$("${LOCAL}/help/texlive-bin.sh")
    echo "${path}" | grep '/bin'
} > "${stdout}" 2>&1
echo "👍🏻 Found TeXLive directory"
