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
output_file="${output_folder}/${metric_name}.median.csv"

if ((count > 0)); then
    if ((count % 2 == 1)); then
        median="${sorted_values[$((count / 2))]}"
    else
        mid1=$((count / 2 - 1))
        mid2=$((count / 2))
        median=$(echo "scale=3; (${sorted_values[$mid1]} + ${sorted_values[$mid2]}) / 2" | bc)
    fi
    formatted_median=$(printf "%0.3f" "$median")
    echo "$formatted_median" > "${output_file}"
    echo "Aggregated median for ${metric_name}: $formatted_median"
else
    echo "0.000" > "${output_file}"
    echo "No valid data to aggregate for ${metric_name}"
fi
