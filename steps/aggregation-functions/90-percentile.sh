#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

metric_file=$1
output_folder=$2
metric_name=$3

mkdir -p "${output_folder}"

values=$(awk -F, 'NR > 1 {print $3}' "${metric_file}")

values_array=()
while IFS= read -r value; do
    if [[ -n "$value" ]]; then
        values_array+=("$value")
    fi
done <<< "$values"

mapfile -t sorted_values < <(for value in "${values_array[@]}"; do echo "$value"; done | sort -n)

count=${#sorted_values[@]}
output_file="${output_folder}/${metric_name}.90th_percentile.csv"

if ((count > 0)); then
    percentile_rank=$(echo "scale=0; $count * 0.9" | bc)
    percentile_rank=${percentile_rank%.*}
    if ((percentile_rank == 0)); then
        percentile_rank=1
    elif ((percentile_rank >= count)); then
        percentile_rank=$count
    fi
    percentile_value="${sorted_values[$((percentile_rank - 1))]}"
    echo "$percentile_value" > "${output_file}"
    echo "Aggregated 90th percentile for ${metric_name}: $percentile_value"
else
    echo "0.000" > "${output_file}"
    echo "No valid data to aggregate for ${metric_name}"
fi
