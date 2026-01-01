#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

metric_file=$1
output_folder=$2
metric_name=$3

mkdir -p "${output_folder}"

sum=0
count=0

values=$(awk -F, 'NR > 1 {print $3}' "${metric_file}")

if [ -n "${values}" ]; then
    while IFS= read -r value; do
        sum=$(echo "${sum} + ${value}" | bc)
        count=$((count + 1))
    done <<< "${values}"
fi

output_file="${output_folder}/${metric_name}.mean.csv"

if ((count > 0)); then
    mean=$(echo "scale=3; $sum / $count" | bc)
    formatted_mean=$(printf "%0.3f" "$mean")
    echo "$formatted_mean" > "${output_file}"
    echo "Aggregated mean for ${metric_name}: ${formatted_mean}"
else
    rm -f "${output_file}"
    echo "No valid data to aggregate for ${metric_name}"
fi
