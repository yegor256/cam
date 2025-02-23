#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
