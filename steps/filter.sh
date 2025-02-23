#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

if [ -f "venv/bin/activate" ]; then
  # shellcheck source=venv/bin/activate disable=SC1091
  . venv/bin/activate
else
  echo "Error: venv/bin/activate not found. Please make sure the virtual environment is set up."
  exit 1
fi
mkdir -p "${TARGET}/temp/reports"
find "${LOCAL}/filters" -type f -name '*.sh' -exec bash -c 'realpath --relative-to="${1}" "$2"' _ "${LOCAL}/filters" {} \; | sort | while IFS= read -r filter; do
    tex=${TARGET}/temp/reports/${filter}.tex
    if [ ! -s "${tex}" ]; then
        echo "The ${filter} filter failed in previous run, cleaning up after it now..."
        rm -f "${tex}"
    fi
    if [ -e "${tex}" ]; then
        echo "The ${filter} filter was already completed earlier, see report in '${tex}'"
    else
        before=$(find "${TARGET}/github" -name '*' -type f -o -type l -o -type d | wc -l | xargs)
        echo "Running filter ${filter}... (may take some time)"
        start=$(date +%s%N)
        "${LOCAL}/filters/${filter}" "${TARGET}/github" "${TARGET}/temp" |\
            tr -d '\n\r' |\
            sed "s/^/\\\\item /" |\
            sed "s/$/;/" \
            > "${tex}"
        after=$(find "${TARGET}/github" -name '*' -type f -o -type l -o -type d | wc -l | xargs)
        if [ "${after}" -lt "${before}" ]; then
            diff="deleted $(echo "${before} - ${after}" | bc) files"
        elif [ "${after}" -gt "${before}" ]; then
            diff="added $(echo "${after} - ${before}" | bc) files"
        else
            diff="didn't touch any files"
        fi
        echo "Filter ${filter} finished$("${LOCAL}/help/tdiff.sh" "${start}"), ${diff} \
and published its results to ${TARGET}/temp/reports/${filter}.tex "
    fi
done

find "${TARGET}/temp/reports" -type f -exec basename {} \; | sort | while IFS= read -r f; do
    echo "${f}:"
    cat "${TARGET}/temp/reports/${f}"
    echo ""
done
