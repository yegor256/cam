#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

"${LOCAL}/steps/catalog.sh"
python3 "${LOCAL}/help/metric-catalog.py" text < "${TARGET}/metrics.csv"
