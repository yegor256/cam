#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

metric_file=$1
output_folder=$2
metric_name=$3

mkdir -p "${output_folder}"

sum=0
count=0

values=$(awk -F, 'NR > 1 {print $3}' "${metric_file}")

while IFS= read -r value; do
    sum=$(echo "$sum + $value" | bc)
    count=$((count + 1))
done <<< "${values}"

if ((count > 0)); then
    mean=$(echo "scale=3; $sum / $count" | bc)
    formatted_mean=$(printf "%0.3f" "$mean")
    output_file="${output_folder}/${metric_name}.mean.csv"
    echo "$formatted_mean" > "${output_file}"
    echo "Aggregated mean for ${metric_name}: $formatted_mean"
else
    echo "No valid data to aggregate for ${metric_name}"
fi
