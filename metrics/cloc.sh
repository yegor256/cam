#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

java=$1
output=$2

out=$(cloc --timeout 0 --quiet --csv "${java}" | tail -1)
IFS=',' read -r -a M <<< "${out}"
cat <<EOT> "${output}"
NoBL ${M[2]} Number of Blank Lines
NoCL ${M[3]} Number of Commenting Lines
LoC ${M[4]} Total physical lines of source code, including commenting lines and blank lines
EOT
