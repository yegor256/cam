#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

temp=$1
stdout=$2

script_location="${LOCAL}/metrics/cc.py"

{
    java_file="${temp}/TestCC.java"
    cat > "${java_file}" <<'EOF'
public class TestCC {
    public void method1() {
        if (true) { System.out.println("Hello"); }
    }
    public void method2() {
        for (int i = 0; i < 10; i++) { System.out.println(i); }
    }
}
EOF

    metrics_file="${temp}/metrics.txt"
    "${script_location}" "${java_file}" "${metrics_file}"
    
    output=$(cat "${metrics_file}")
    echo "${output}"
    
    echo "${output}" | grep "CoCo 2 " || { echo "Error: Cognitive Complexity not as expected"; exit 1; }
} > "${stdout}" 2>&1

echo "👍 Cognitive Complexity calculated correctly"
