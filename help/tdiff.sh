#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

start=$1
if [ -z "${start}" ]; then
    echo 'One argument is required'
    exit 1
fi

pfx=', in '
mks=$(echo "($(date +%s%N) - ${start}) / 1000" | bc)
if ((mks < 100)); then
    exit
elif ((mks < 1000)); then
    printf '%s%dμs' "${pfx}" "${mks}"
elif ((mks < 1000 * 1000)); then
    printf '%s%dms' "${pfx}" "$((mks / 1000))"
elif ((mks < 60 * 1000 * 1000)); then
    printf '%s%ds' "${pfx}" "$((mks / (1000 * 1000)))"
elif ((mks < 60 * 60 * 1000 * 1000)); then
    minutes=$((mks / (60 * 1000 * 1000)))
    seconds=$(((mks - minutes * 60 * 1000 * 1000) / (1000 * 1000)))
    printf '%s%dm%ds' "${pfx}" "${minutes}" "${seconds}"
else
    hours=$((mks / (60 * 60 * 1000 * 1000)))
    minutes=$(((mks - hours * 60 * 60 * 1000 * 1000) / (60 * 1000 * 1000)))
    printf '%s%dh%dm' "${pfx}" "${hours}" "${minutes}"
fi
