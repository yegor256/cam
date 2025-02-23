#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
        while IFS= read -r file; do
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
        done < <(echo "$files")
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
