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

java=$1
output=$2

if [[ ! "$(realpath --relative-to="${TARGET}/github" "${java}")" =~ ^\.\. ]]; then
    exit
fi

cat <<EOT> "${output}"
MMAC 0 Method-Method through Attributes Cohesion~\citep{dallal2012}
CAMC 0 Cohesion Among Methods in Class~\citep{bansiya1999class}
NHD 0 Normalized Hamming Distance~\citep{counsell2006}
LCOM5 0 Revision of the initial LCOM metric~\citep{HendersonSellers1996}
SCOM 0 Sensitive Class Cohesion Metric~\citep{fernandez2006}
MMAC-cvc 0 Same as MMAC, but constructors are excluded
CAMC-cvc 0 Same as CAMC, but constructors are excluded
NHD-cvc 0 Same as NHD, but constructors are excluded
LCOM5-cvc 0 Same as LCOM5, but constructors are excluded
SCOM-cvc 0 Same as SCOM, but constructors are excluded
EOT
