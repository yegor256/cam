#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

csv=${TARGET}/repositories.csv

if [ ! -e "${csv}" ]; then
    echo "Nothing to unregister, the CSV is absent: ${csv}"
    exit
fi

before="${TARGET}/temp/repositories-before-unregister.txt"
mkdir -p "$(dirname "${before}")"
tail -n +2 "${csv}" > "${before}"

head=$(head -1 "${csv}")
rm -f "${csv}"
echo "${head}" > "${csv}"

declare -i total=0
declare -i good=0
while IFS=',' read -r r tag tail; do
    if [ -z "${r}" ]; then
      continue;
    fi
    total=$((total+1))
    if [ ! -e "${TARGET}/github/${r}" ]; then
        echo "The clone of ${r} is absent, unregistered"
    else
        printf "%s,%s,%s\n" "${r}" "${tag}" "${tail}" >> "${csv}"
        good=$((good+1))
    fi
done < "${before}"
echo "All ${total} repositories checked, ${good} are good"
