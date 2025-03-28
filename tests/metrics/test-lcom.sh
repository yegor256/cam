#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

temp=$1
stdout=$2

script_location="${LOCAL}/metrics/lcom.py"

{
    java_file="${temp}/TestLCOM.java"
    cat > "${java_file}" <<'EOF'
public class TestLCOM {
    private int a;
    private int b;
    
    public void method1() {
        System.out.println(a);
    }
    
    public void method2() {
        System.out.println(b);
    }
    
    public void method3() {
        System.out.println(a);
        System.out.println(b);
    }
}
EOF

    metrics_file="${temp}/metrics.txt"
    "${script_location}" "${java_file}" "${metrics_file}"
    
    output=$(cat "${metrics_file}")
    echo "${output}"
    
    grep "LCOM 0 " "${metrics_file}" || { echo "Error: LCOM value is not 0 as expected"; exit 1; }
} > "${stdout}" 2>&1

echo "👍 Correctly calculated Lack of Cohesion of Methods (LCOM)"
