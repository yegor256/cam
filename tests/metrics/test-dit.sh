#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

temp=$1
stdout=$2

script_location="${LOCAL}/metrics/dit.py"

{
    java_file="${temp}/TestDIT.java"
    cat > "${java_file}" <<'EOF'
        public class A extends B {}
        class B {}
EOF
    metrics_file="${temp}/metrics.txt"
    "${script_location}" "${java_file}" "${metrics_file}"
    output=$(cat "${metrics_file}")
    echo "${output}"
    expected_value="2"
    grep -q "DIT ${expected_value} " "${metrics_file}" || {
      echo "Error: Expected DIT ${expected_value} not found in output:";
      echo "${output}";
      exit 1;
    }
} > "${stdout}" 2>&1
echo "👍 Depth of Inheritance Tree (DIT) was calculated correctly with value ${expected_value}"
