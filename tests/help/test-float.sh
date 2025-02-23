#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

num=$(echo '.42' | "${LOCAL}/help/float.sh")
test "${num}" = '0.420'
echo "${num}" >> "${stdout}"
echo "👍🏻 Corrected floating point number"

test "$(echo '254.42' | "${LOCAL}/help/float.sh")" = '254.420'
echo "👍🏻 Corrected longer floating point number"

test "$(echo '256' | "${LOCAL}/help/float.sh")" = '256.000'
echo "👍🏻 Corrected integer number"

test "$(echo '09' | "${LOCAL}/help/float.sh")" = '9.000'
echo "👍🏻 Corrected integer number with leading zero"

test "$(echo '' | "${LOCAL}/help/float.sh")" = '0.000'
echo "👍🏻 Corrected integer number with empty text"

test "$(echo '  ' | "${LOCAL}/help/float.sh")" = '0.000'
echo "👍🏻 Corrected integer number with spaces"

test "$(echo 'Blank' | "${LOCAL}/help/float.sh")" = '0.000'
echo "👍🏻 Corrected integer number with text input"

test "$(echo 'NaN' | "${LOCAL}/help/float.sh")" = 'NaN'
echo "👍🏻 Corrected integer number with NaN"

test "$(echo '.000000099' | "${LOCAL}/help/float.sh")" = '0.000'
echo "👍🏻 Corrected small precision number"

test "$(echo '254' | "${LOCAL}/help/float.sh")" = '254.000'
echo "👍🏻 Printed decimal number with 3 digits"

test "$(echo '0.3' | "${LOCAL}/help/float.sh")" = '0.300'
echo "👍🏻 Printed decimal number with 3 digits"

test "$(echo '0.00023' | "${LOCAL}/help/float.sh")" = '0.000'
echo "👍🏻 Printed decimal number with 3 digits"
