#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

java=$1
output=$(realpath "$2")

tmp=$(mktemp -d)
mkdir -p "${tmp}"

cat <<EOT > "${tmp}/config.xml"
<?xml version="1.0" encoding="UTF-8"?>
<ruleset name="CAM_bug_discover" xmlns="http://pmd.sourceforge.net/ruleset/2.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://pmd.sourceforge.net/ruleset/2.0.0 https://pmd.sourceforge.io/ruleset_2_0_0.xsd">
    <description>Bug discovering</description>
    <rule ref="category/java/errorprone.xml"/>
</ruleset>
EOT
cp "${java}" "${tmp}/foo.java"

export PMD_JAVA_OPTS=${JVM_OPTS}
# We don't use --cache here, because it becomes too big and leads to "Out Of Memory" error
pmd check -R "${tmp}/config.xml" -d "${tmp}" --format xml --no-fail-on-error --no-fail-on-violation > "${tmp}/result.xml" 2> "${tmp}/stderr.txt" || (cat "${tmp}/stderr.txt"; exit 1)

violation_num=$(awk '/<violation/ {count++} END {print count+0}' "${tmp}/result.xml")
printf "BugNum %s The number of issues detected by PMD\n" "${violation_num}" > "${output}"
