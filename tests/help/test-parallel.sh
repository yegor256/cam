#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

stdout=$2

jobs=${TARGET}/jobs.txt
for i in A B C D E F G H I J; do
    echo "echo -n ${i}" >> "${jobs}"
done
msg=$("${LOCAL}/help/parallel.sh" "${jobs}")
echo "${msg}" >> "${stdout}"
test "${#msg}" = '10'
echo "👍🏻 Correctly ran parallel"

jobs=${TARGET}/jobs-2.txt
q=0
while [[ q -lt 1000 ]]; do
    q=$(( q + 1 ))
    echo 'printf ""' >> "${jobs}"
done
test "$("${LOCAL}/help/parallel.sh" "${jobs}")" = ''
echo "👍🏻 Correctly ran parallel with large input"
