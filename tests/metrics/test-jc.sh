#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

# Setup temporary workspace
temp=$1
stdout=$2

# Location of the Python metric script
script_location="${LOCAL}/metrics/jc.py"

{
    # Create a sample Java file that includes both documented and undocumented methods
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

    # Run Javadoc coverage script
    metrics_file="${temp}/metrics.txt"
    "${script_location}" "${java_file}" "${metrics_file}"
    cat "${metrics_file}"


    grep "JDC 0.666" "${metrics_file}" \
      || grep "JDC 0.66" "${metrics_file}" \
      || grep "JDC 0.67" "${metrics_file}"
} > "${stdout}" 2>&1

echo "👍 Javadoc coverage was calculated correctly"
