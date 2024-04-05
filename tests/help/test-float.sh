#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
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
