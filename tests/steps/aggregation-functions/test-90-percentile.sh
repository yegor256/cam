#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

stdout=$2

{
    dir="${TARGET}"
    mkdir -p "${dir}"
    touch "${dir}/LCOM5.csv"
    echo "repo,java_file,LCOM5" > "${dir}/LCOM5.csv"
    echo "kek,src/main/kek,42.000" >> "${dir}/LCOM5.csv"
    "${LOCAL}/steps/aggregation-functions/90-percentile.sh" "${dir}/LCOM5.csv" "${TARGET}/data/aggregation" "LCOM5"
    test -e "${TARGET}/data/aggregation/LCOM5.90th_percentile.csv"
    percentile_value=$(cat "${TARGET}/data/aggregation/LCOM5.90th_percentile.csv")
} > "${stdout}" 2>&1
echo "👍🏻 Single metric (LCOM5) 90th percentile calculated correctly"

{
    dir1="${TARGET}"
    mkdir -p "${dir1}"
    touch "${dir1}/LCOM5.csv"
    echo "repo,java_file,LCOM5" > "${dir1}/LCOM5.csv"
    echo "kek,src/main/kek,42.000" >> "${dir1}/LCOM5.csv"
    touch "${dir1}/NHD.csv"
    echo "repo,java_file,NHD" > "${dir1}/NHD.csv"
    echo "kek,src/main/kek,1000.000" >> "${dir1}/NHD.csv"
    "${LOCAL}/steps/aggregation-functions/90-percentile.sh" "${dir1}/LCOM5.csv" "${TARGET}/data/aggregation" "LCOM5"
    "${LOCAL}/steps/aggregation-functions/90-percentile.sh" "${dir1}/NHD.csv" "${TARGET}/data/aggregation" "NHD"
    test -e "${TARGET}/data/aggregation/LCOM5.90th_percentile.csv"
    percentile_value_lcom5=$(cat "${TARGET}/data/aggregation/LCOM5.90th_percentile.csv")
    test "$percentile_value_lcom5" = "42.000"
    test -e "${TARGET}/data/aggregation/NHD.90th_percentile.csv"
    percentile_value_nhd=$(cat "${TARGET}/data/aggregation/NHD.90th_percentile.csv")
    test "$percentile_value_nhd" = "1000.000"
} > "${stdout}" 2>&1
echo "👍🏻 Multiple metrics (LCOM5, NHD) aggregated correctly"
{
    dir="${TARGET}"
    mkdir -p "${dir}"
    touch "${dir}/Empty.java.m.LCOM5"
    echo "repo,java_file,LCOM5" > "${dir}/Empty.java.m.LCOM5"
    "${LOCAL}/steps/aggregation-functions/90-percentile.sh" "${dir}/Empty.java.m.LCOM5" "${TARGET}/data/aggregation" "LCOM5"
    test -e "${TARGET}/data/aggregation/LCOM5.90th_percentile.csv"
    percentile_value=$(cat "${TARGET}/data/aggregation/LCOM5.90th_percentile.csv")
    test "$percentile_value" = "0.000"
} > "${stdout}" 2>&1
echo "👍🏻 Edge case with no data handled correctly"
