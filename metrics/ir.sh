#!/usr/bin/env bash


# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

output=$(realpath "$2")

echo "IR 0.000 " >"${output}"
