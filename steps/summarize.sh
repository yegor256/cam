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

summary_dir="${TARGET}/data/summary"
mkdir -p "${summary_dir}"
metrics=$(find "${TARGET}/measurements" -type f -name '*.m.*' -print | sed "s|^.*\.\(.*\)$|\1|" | sort | uniq)
metrics_count=0

for metric in ${metrics}; do
    summary_file="${summary_dir}/${metric}.csv"
    echo "repository,count,sum,average,mean,min,max" > "${summary_file}"
    while IFS= read -r repo; do
        files=$(find "${TARGET}/measurements/${repo}" -type f -name "*.${metric}")
        count=0
        sum=0
        min=999999
        max=0
        all_values=()
        if [[ -z $files ]]; then
            continue
        fi
        for file in ${files}; do
            value=$(cat "${file}")
            if [[ -z "$value" || ! "$value" =~ ^[0-9]+$ ]]; then
                continue
            fi
            count=$((count + 1))
            sum=$((sum + value))
            all_values+=("${value}")
            if ((value < min)); then
                min=${value}
            fi
            if ((value > max)); then
                max=${value}
            fi
        done
        if [[ ${count} -gt 0 ]]; then
            average=$(echo "scale=2; ${sum} / ${count}" | bc -l)
        else
            average=0
        fi
        if [[ ${#all_values[@]} -gt 0 ]]; then
            mapfile -t sorted_values < <(printf "%s\n" "${all_values[@]}" | sort -n)
            middle_index=$((count / 2))
            if ((count % 2 == 0)); then
                mean=$(echo "scale=2; (${sorted_values[$((middle_index-1))]} + ${sorted_values[$middle_index]}) / 2" | bc -l)
            else
                mean=${sorted_values[middle_index]}
            fi
        else
            mean=0
        fi
        echo "${repo},${count},${sum},${average},${mean},${min},${max}" >> "${summary_file}"
    done < "${TARGET}/temp/repos-to-aggregate.txt"
    metrics_count=$((metrics_count + 1))
    echo "Metric ${metric} summarized in ${summary_file}."
done
echo "All ${metrics_count} metrics summarized into ${summary_dir}."
