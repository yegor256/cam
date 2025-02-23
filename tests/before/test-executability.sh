#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

declare -a excludes=()
for e in dataset lib pylint_plugins venv; do
    excludes+=(-not -path "${LOCAL}/${e}/**")
done

{
    scripts=$(find "${LOCAL}" "${excludes[@]}" -type f -name '*.sh')
    echo "${scripts}" | while IFS= read -r sh; do
        if [ ! -x "${sh}" ]; then
            echo "Script '${sh}' is not executable, try running 'chmod +x ${sh}'"
            exit 1
        fi
    done
    echo "All $(echo "${scripts}" | wc -w | xargs) scripts are executable, it's OK"
} > "${stdout}" 2>&1
echo "👍🏻 All .sh scripts are executable"

{
    scripts=$(find "${LOCAL}" "${excludes[@]}" -type f -name '*.py')
    echo "${scripts}" | while IFS= read -r py; do
        if [ ! -x "${py}" ]; then
            echo "Script '${py}' is not executable, try running 'chmod +x ${py}'"
            exit 1
        fi
    done
    echo "All $(echo "${scripts}" | wc -w | xargs) scripts are executable, it's OK"
} > "${stdout}" 2>&1
echo "👍🏻 All .py scripts are executable"
