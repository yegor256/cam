#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

temp=$1
stdout=$2

script_location="${LOCAL}/metrics/aml.py"

{
    java_file="${temp}/TestAML.java"
    cat > "${java_file}" <<'EOT'
public class TestAML {
    public void shortMethod() { int a = 1; }
    public void longMethod() {
        System.out.println("Line 1");
        System.out.println("Line 2");
        System.out.println("Line 3");
    }
}
EOT

    metrics_file="${temp}/metrics.txt"
    "${script_location}" "${java_file}" "${metrics_file}"
    output=$(cat "${metrics_file}")
    echo "${output}"
    echo "${output}" | grep "AML" || { echo "Error: AML metric not found"; exit 1; }
    echo "${output}" | grep "Average Method Length" || { echo "Error: Metric description not found"; exit 1; }
} > "${stdout}" 2>&1

echo "👍🏻 Average Method Length was calculated correctly"
