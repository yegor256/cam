#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

output=$(realpath "$2")

# REPLACE WITH ACTUAL METRIC CODE
echo "IRCA 0.000 " >"${output}"
