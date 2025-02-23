#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

jobs=$1
x=$2
if [ -z "${x}" ]; then
  x=1;
fi

cores=$(echo "$(nproc) * ${x}" | bc)
args=(
  '--halt-on-error=now,fail=1'
  '--halt=now,fail=1'
  '--retries=3'
  "--load=8"
  "--joblog=${jobs}.log"
  "--max-procs=${cores}"
  "--will-cite"
)
uniq "${jobs}" | parallel "${args[@]}"
