#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

LOCAL_METRICS=${LOCAL_METRICS:-${LOCAL}/metrics}
mkdir -p "${TARGET}/temp"
if [ -f "${LOCAL}/venv/bin/activate" ]; then
    # shellcheck source=/dev/null
    . "${LOCAL}/venv/bin/activate"
fi

raw=${TARGET}/temp/metric-catalog.txt
: > "${raw}"
java=${TARGET}/temp/MetricCatalog.java
find "${LOCAL_METRICS}" -type f -exec test -x {} \; -print | sort | while IFS= read -r calculator; do
    echo 'class MetricCatalog {}' > "${java}"
    metric=${TARGET}/temp/metric-catalog.m
    rm -f "${metric}"
    "${calculator}" "${java}" "${metric}"
    cat "${metric}" >> "${raw}"
done
if [ ! -s "${raw}" ]; then
    echo "No metric generating files found, probably an internal error" >&2
    exit 1
fi
python3 "${LOCAL}/help/metric-catalog.py" csv < "${raw}" > "${TARGET}/metrics.csv"
