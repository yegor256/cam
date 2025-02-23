#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

{
    dirs=$(find "${LOCAL}/tests" -mindepth 1 -maxdepth 1 -type d -not -name "before" -not -name "after" -exec basename {} \;)
    echo "${dirs}" | while IFS= read -r d; do
        tests=$(find "${LOCAL}/tests/${d}" -mindepth 1 -maxdepth 1 -type f -name '*.sh' -exec basename {} \;)
        echo "${tests}" | while IFS= read -r t; do
            tail=${t:5:100}
            base=${tail%.*}
            name=${d}/${tail}
            if [ "$(find "${LOCAL}/${d}" -name "${base}.*" 2>/dev/null | wc -l)" -eq 0 ]; then
                echo "Script '${name}' doesn't exist, but its test exists in '${LOCAL}/tests/${d}/${t}'"
                exit 1
            fi
        done
    done
} > "${stdout}" 2>&1
echo "👍🏻 All test scripts have their live counterparts"
