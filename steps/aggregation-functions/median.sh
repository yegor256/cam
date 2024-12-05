#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
