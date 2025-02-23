#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=${LOCAL}/test-zone
mkdir -p "${temp}"

export CAMTESTS=1

dir="${LOCAL}/tests"
tests=$(
    find "${dir}" -mindepth 2 -type f -name '*.sh' -path "${dir}/before/**";
    find "${dir}" -mindepth 2 -type f -name '*.sh' -not -path "${dir}/before/**" -not -path "${dir}/after/**" | sort;
    find "${dir}" -mindepth 2 -type f -name '*.sh' -path "${dir}/after/**"
)
echo "There are $(echo "${tests}" | wc -l | xargs) tests in ${dir}"
echo "${tests}" | while IFS= read -r test; do
    name=$(realpath --relative-to="${LOCAL}/tests" "${test}")
    if [ -n "${TEST}" ] && [ ! "${TEST}" = "${name}" ] && [ ! "${TEST}" = "tests/${name}" ]; then
        echo "Skipped ${name}"
        continue
    fi
    echo -e "\n${name}:"
    t=${temp}/${name}
    if [ -e "${t}" ]; then
        rm -rf "${t}"
    fi
    mkdir -p "${t}"
    tgt=${t}/target
    if [ -e "${tgt}" ]; then
        rm -rf "${tgt}"
    fi
    mkdir -p "${tgt}"
    stdout=${t}/stdout.log
    mkdir -p "$(dirname "${stdout}")"
    touch "${stdout}"
    if ! TARGET="${tgt}" "${test}" "${t}" "${stdout}"; then
        if [ ! -e "${stdout}" ]; then
            echo "Can't find log file after a failed test: ${stdout}"
            tree "${t}/"
        else
            cat "${stdout}"
        fi
        echo "❌ Non-zero exit code (TARGET=${tgt})"
        echo "You can run this particular test in isolation: make test TEST=tests/${name}"
        exit 1
    fi
done
