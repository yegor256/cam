#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

start=$(( $(date +%s%N) - 5 * 1000 * 1000 * 1000 ))
diff=$("${LOCAL}/help/tdiff.sh" "${start}")
test "${diff}" = ', in 5s'
echo "${diff}" >> "${stdout}"
echo "👍🏻 Correctly calculated seconds"

start=$(( $(date +%s%N) - 7 * 60 * 1000 * 1000 * 1000 - 15 * 1000 * 1000 * 1000 ))
test "$("${LOCAL}/help/tdiff.sh" "${start}")" = ', in 7m15s'
echo "👍🏻 Correctly calculated minutes"

start=$(( $(date +%s%N) - 3 * 60 * 60 * 1000 * 1000 * 1000 ))
test "$("${LOCAL}/help/tdiff.sh" "${start}")" = ', in 3h0m'
echo "👍🏻 Correctly calculated hours"

start=$(( $(date +%s%N) - 3 * 60 * 60 * 1000 * 1000 * 1000 + 25 * 60 * 1000 * 1000 * 1000 ))
test "$("${LOCAL}/help/tdiff.sh" "${start}")" = ', in 2h35m'
echo "👍🏻 Correctly calculated hours and minutes"
