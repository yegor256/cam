#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2023 Yegor Bugayenko
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

java=$1
output=$2

sample="MMAC NaN Method-Method through Attributes Cohesion.
CAMC NaN Cohesion Among Methods in Class
NHD NaN Normalized Hamming Distance
LCOM5 NaN Revision of the initial LCOM metric
SCOM NaN Sensitive Class Cohesion Metric
MMAC-cvc NaN Same as MMAC, but constructors are excluded
CAMC-cvc NaN Same as CAMC, but constructors are excluded
NHD-cvc NaN Same as NHD, but constructors are excluded
LCOM5-cvc NaN Same as LCOM5, but constructors are excluded
SCOM-cvc NaN Same as SCOM, but constructors are excluded"

file="${java//github/jpeek}"
out=""
if [ -e "${file}" ] && [ "${file}" != "${java}" ]; then
	out="$(cat "${file}")"
else
	out="${sample}"
fi

cat <<EOT> "${output}"
${out}
EOT
