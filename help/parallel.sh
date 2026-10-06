#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

jobs=$1
x=$2
if [ -z "${x}" ]; then
  x=1;
fi

# Raise the open-file soft limit to the hard limit so that GNU parallel
# does not print "Only enough file handles to run N jobs in parallel".
hard=$(ulimit -Hn 2>/dev/null || echo "")
if [ -n "${hard}" ] && [ "${hard}" != "unlimited" ]; then
  ulimit -n "${hard}" 2>/dev/null || true
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
