#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
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
CAMC NaN The Cohesion Among Methods in Class (CAMC).
NHD NaN The NHD (Normalized Hamming Distance) class cohesion metric.
LCOM5 NaN 'LCOM5' is a 1996 revision by B. Henderson-Sellers, L. L. Constantine, and I. M. Graham, of the initial LCOM metric.
SCOM NaN \"Sensitive Class Cohesion Metric\" (SCOM) notes some deficits in the LCOM5 metric.
MMAC(cvc) NaN Same as MMAC, but in this case, the constructors are excluded from the metric formulas.
CAMC(cvc) NaN Same as CAMC, but in this case, the constructors are excluded from the metric formulas.
NHD(cvc) NaN Same as NHD, but in this case, the constructors are excluded from the metric formulas.
LCOM5(cvc) NaN Same as LCOM5, but in this case, the constructors are excluded from the metric formulas.
SCOM(cvc) NaN Same as SCOM, but in this case, the constructors are excluded from the metric formulas."

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
