#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

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

# A low inherited soft limit must not restrict GNU parallel's job capacity.
jobs=${TARGET}/jobs-low-limit.txt
for i in {1..80}; do
    echo "true ${i}" >> "${jobs}"
done
(
    ulimit -Sn 64
    "${LOCAL}/help/parallel.sh" "${jobs}" 100
) 2> "${TARGET}/parallel-low-limit.stderr"
if grep -q 'file handles' "${TARGET}/parallel-low-limit.stderr"; then
    cat "${TARGET}/parallel-low-limit.stderr"
    exit 1
fi
echo "👍🏻 Raised the inherited open-file soft limit"
