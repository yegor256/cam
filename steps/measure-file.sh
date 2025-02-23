#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

java=$1
javam=$2
pos=$3
total=$4

start=$(date +%s%N)

mkdir -p "$(dirname "${javam}")"
touch "${javam}"
metrics=$(find "${LOCAL}/metrics/" -type f -exec test -x {} \; -exec basename {} \;)
echo "${metrics}" | {
    sum=0
    while IFS= read -r m; do
        if timeout 30m "metrics/${m}" "${java}" "${javam}"; then
            while IFS= read -r t; do
                IFS=' ' read -r -ra M <<< "${t}"
                value=$(echo "${M[1]}" | "${LOCAL}/help/float.sh")
                echo "${value}" > "${javam}.${M[0]}"
                if [ ! "${value}" = "NaN" ]; then
                    sum=$(echo "${sum} + ${value}" | bc | "${LOCAL}/help/float.sh")
                fi
            done < "${javam}"
        else
            echo "Failed to collect ${m} for ${java}"
        fi
    done
    echo "$(echo "${metrics}" | wc -w | xargs) scripts \
collected $(find "$(dirname "${javam}")" -type f -name "$(basename "${javam}").*" | wc -l | xargs) metrics (sum=${sum}) \
for: $(basename "${java}") (${pos}/${total})$("${LOCAL}/help/tdiff.sh" "${start}")"
}
