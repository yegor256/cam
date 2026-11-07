#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

if [[ "$OSTYPE" == "darwin"* ]]; then
  exit 0
else
  exit 1
fi
