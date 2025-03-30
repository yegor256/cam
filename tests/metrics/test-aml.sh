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
    expected_value="3.0"
    echo "${output}" | grep -q "AML ${expected_value} " || {
        echo "Error: Expected AML ${expected_value} not found in output:";
        echo "${output}";
        exit 1;
    }
    echo "${output}" | grep -q "Average Method Length" || {
        echo "Error: Metric description 'Average Method Length' not found";
        exit 1;
    }
} > "${stdout}" 2>&1
echo "👍🏻 Average Method Length was calculated correctly with value ${expected_value}"

{
    java_file="${temp}/EmptyTest.java"
    cat > "${java_file}" <<'EOT'
public class EmptyClass {
}
EOT
    metrics_file="${temp}/metrics_empty_class.txt"
    "${script_location}" "${java_file}" "${metrics_file}"
    output=$(cat "${metrics_file}")
    expected_value="0.0"
    echo "${output}" | grep -q "AML ${expected_value} " || {
        echo "Error: Expected AML ${expected_value} not found in output for empty class:";
        echo "${output}";
        exit 1;
    }
    echo "${output}" | grep -q "Average Method Length" || {
        echo "Error: Metric description 'Average Method Length' not found in output for empty class";
        exit 1;
    }
    echo "👍🏻 Average Method Length was calculated correctly for empty class with value ${expected_value}"
} > "${stdout}" 2>&1
echo "👍🏻 All tests passed successfully."