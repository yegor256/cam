#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

if [[ "$OSTYPE" == "darwin"* ]]; then
  exit 0
else
  exit 1
fi
