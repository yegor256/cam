#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

{
    "${LOCAL}/help/assert-tool.sh" echo hello
} > "${stdout}" 2>&1
echo "👍🏻 Positive assertion works"

{
    if "${LOCAL}/help/assert-tool.sh" bla-bla-bla; then
        exit 1
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Negative assertion works"
