#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

temp=$1
stdout=$2

script_location="${LOCAL}/metrics/cbo.py"

{
    java_file="${temp}/TestCBO.java"
    cat > "${java_file}" <<'EOF'
public class TestCBO extends BaseClass implements InterfaceX, InterfaceY {
    private ExternalA fieldA;
    private ExternalB fieldB;

    public ExternalD method1(ExternalC param) {
        return null;
    }
    
    public void method2() {}
}
EOF
    metrics_file="${temp}/metrics.txt"
    "${script_location}" "${java_file}" "${metrics_file}"
    output=$(cat "${metrics_file}")
    echo "${output}"
    expected_value="7"
    grep -q "CBO ${expected_value} " "${metrics_file}" || {
      echo "Error: Expected CBO ${expected_value} not found in output:"
      echo "${output}"
      exit 1
    }
} > "${stdout}" 2>&1
echo "👍 Coupling Between Objects (CBO) was calculated correctly with value ${expected_value}"
