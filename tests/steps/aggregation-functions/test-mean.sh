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
    echo "kek,src/main/kek,42.0000" >> "${dir}/LCOM5.csv"
    "${LOCAL}/steps/aggregation-functions/mean.sh" "${dir}/LCOM5.csv" "${TARGET}/data/aggregation" "LCOM5"
    test -e "${TARGET}/data/aggregation/LCOM5.mean.csv"
    mean_value=$(cat "${TARGET}/data/aggregation/LCOM5.mean.csv")
    test "$mean_value" = "42.000"
} > "${stdout}" 2>&1
echo "👍🏻 Single metric (LCOM5) mean calculated correctly"


{
    dir1="${TARGET}"
    mkdir -p "${dir1}"
    touch "${dir1}/LCOM5.csv"
    echo "repo,java_file,LCOM5" > "${dir1}/LCOM5.csv"
    echo "kek,src/main/kek,42.000" >> "${dir1}/LCOM5.csv"
    touch "${dir1}/NHD.csv"
    echo "repo,java_file,NHD" > "${dir1}/NHD.csv"
    echo "kek,src/main/kek,1000.000" >> "${dir1}/NHD.csv"
    "${LOCAL}/steps/aggregation-functions/mean.sh" "${dir1}/LCOM5.csv" "${TARGET}/data/aggregation" "LCOM5"
    "${LOCAL}/steps/aggregation-functions/mean.sh" "${dir1}/NHD.csv" "${TARGET}/data/aggregation" "NHD"
    test -e "${TARGET}/data/aggregation/LCOM5.mean.csv"
    mean_value_lcom5=$(cat "${TARGET}/data/aggregation/LCOM5.mean.csv")
    test "$mean_value_lcom5" = "42.000"
    test -e "${TARGET}/data/aggregation/NHD.mean.csv"
    mean_value_nhd=$(cat "${TARGET}/data/aggregation/NHD.mean.csv")
    test "$mean_value_nhd" = "1000.000"
} > "${stdout}" 2>&1
echo "👍🏻 Multiple metrics (LCOM5, NHD) aggregated correctly"


{
    dir1="${TARGET}"
    mkdir -p "${dir1}"
    touch "${dir1}/First.java.m.LCOM5"
    echo "repo,java_file,LCOM5" > "${dir1}/LCOM5.csv"
    {
      echo "kek,src/main/kek,42.000"
      echo "kek,src/main/kek,35.000"
      echo "kek,src/main/kek,50.000"
    } >> "${dir1}/LCOM5.csv"
    "${LOCAL}/steps/aggregation-functions/mean.sh" "${dir1}/LCOM5.csv" "${TARGET}/data/aggregation" "LCOM5"
    test -e "${TARGET}/data/aggregation/LCOM5.mean.csv"
    mean_value=$(cat "${TARGET}/data/aggregation/LCOM5.mean.csv")
    test "$mean_value" = "42.333"
} > "${stdout}" 2>&1
echo "👍🏻 Mixed metrics aggregated correctly (LCOM5)"

{
    dir="${TARGET}"
    mkdir -p "${dir}"
    touch "${dir}/Empty.java.m.LCOM5"
    echo "repo,java_file,LCOM5" > "${dir}/Empty.java.m.LCOM5"
    "${LOCAL}/steps/aggregation-functions/mean.sh" "${dir}/Empty.java.m.LCOM5" "${TARGET}/data/aggregation" "LCOM5"
    test -e "${TARGET}/data/aggregation/LCOM5.mean.csv"
    mean_value=$(cat "${TARGET}/data/aggregation/LCOM5.mean.csv")
    test "$mean_value" = "0.000"
} > "${stdout}" 2>&1
echo "👍🏻 Edge case with no data handled correctly"
