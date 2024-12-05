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
