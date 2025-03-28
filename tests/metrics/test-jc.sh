#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

temp=$1
stdout=$2

script_location="${LOCAL}/metrics/jc.py"

{
    java_file="${temp}/TestDoc.java"
    cat > "${java_file}" <<EOT
public class TestDoc {
    /**
     * This is a documented method.
     */
    public void documented() {}

    public void notDocumented() {}

    /**
     * Another documented method.
     */
    public void alsoDocumented() {}
}
EOT
    metrics_file="${temp}/metrics.txt"
    "${script_location}" "${java_file}" "${metrics_file}"
    output=$(cat "${metrics_file}")
    echo "${output}"
    grep -q "JDC 0.67 " "${metrics_file}" || {
        echo "Error: Expected JDC 0.67 not found in output:";
        echo "${output}";
        exit 1;
    }
} > "${stdout}" 2>&1
echo "👍 Javadoc coverage was calculated correctly"
