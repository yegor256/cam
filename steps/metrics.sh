#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set +x
set -e -o pipefail

if [ -z "${LOCAL_METRICS}" ]; then
  LOCAL_METRICS=${LOCAL}/metrics
fi

list=${TARGET}/temp/list-of-metrics.txt
rm -f "${list}"
touch "${list}"

java=${TARGET}/temp/Foo.java
if [ -f "venv/bin/activate" ]; then
  # shellcheck source=venv/bin/activate disable=SC1091
  . venv/bin/activate
else
  echo "Error: venv/bin/activate not found. Please make sure the virtual environment is set up."
  exit 1
fi
mkdir -p "$(dirname "${java}")"
find "${LOCAL_METRICS}" -type f -exec test -x {} \; -exec basename {} \; | while IFS= read -r m; do
    echo "class Foo {}" > "${java}"
    metric=${TARGET}/temp/Foo.${m}.m
    rm -f "${metric}"
    "${LOCAL_METRICS}/${m}" "${java}" "${metric}"
    awk '{ s = $1 ": "; for (i = 3; i <= NF; i++) s = s $i " "; print s; }' < "${metric}" >> "${list}"
done

if [ ! -s "${list}" ]; then
    echo "No metric generating files found, probably an internal error"
    exit 1
fi

clean_list=$(sed -E 's/\\citep\{[^}]+\}//g; s/\\textbf\{//g; s/\\href\{[^}]+\}\{([^}]+)\}/\1/g; s/\\[a-zA-Z]+\{([^}]+)\}/\1/g; s/~\s*/ /g' "${list}")
echo "${clean_list}"

total_metrics=$(echo "${clean_list}" | grep -c '^[^[:space:]]')
echo "Total metrics: ${total_metrics}"