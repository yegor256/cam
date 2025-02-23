#!/usr/bin/env bash
# The MIT License (MIT)
#
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

output=$(realpath "$2")

echo "IRLoC 0.000 " >"${output}"
