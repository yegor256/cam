#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

cmd=$1
arg=$2

if [ -z "${TARGET}" ]; then
  TARGET=$(dirname "$0")/../target
fi

out=${TARGET}/temp/assert-tool.out
mkdir -p "$(dirname "${out}")"
if ! "${cmd}" "${arg}" > "${out}" 2>&1; then
    cat "${out}"
    echo "I can't continue, because '${cmd}' command line tool is not available."
    echo "Try to install it somehow and then restart me."
    exit 1
fi
