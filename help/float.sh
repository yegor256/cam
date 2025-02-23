#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

#!/bin/bash
is_float() {
    local re="^-?[0-9]*\.?[0-9]+$"
    [[ $1 =~ $re ]]
}

set -e
set -o pipefail

num=$(cat)

if [[ -z "${num}" || "${num}" =~ ^[[:space:]]+$ ]]; then
    echo "0.000"
    exit
fi

if [ "${num}" == 'NaN' ]; then
    printf '%s' "${num}"
    exit
fi
if ! is_float "$num"; then
    echo "0.000"
    exit 1
fi

num_truncated=$(echo "$num * 1000 / 1" | bc)
LC_NUMERIC=C printf '%.3f' "$(echo "$num_truncated / 1000" | bc -l)" 2>/dev/null || echo "0.000"
