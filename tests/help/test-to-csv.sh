#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

test "$(echo 'a b c' | "${LOCAL}/help/to-csv.sh")" = 'a b c'
echo "👍🏻 Correctly formatted simple text"

test "$(echo 'a,b,c' | "${LOCAL}/help/to-csv.sh")" = 'a\,b\,c'
echo "👍🏻 Correctly formatted commas"
