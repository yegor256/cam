#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

temp=$2

if [ ! -e "${temp}/gits" ]; then
  exit;
fi

repos=${temp}/git-repos-moving-back.txt

find "${temp}/gits" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'realpath --relative-to="${1}" "$2"' _ "${temp}/gits" {} \; > "${repos}"

if [ -s "${repos}" ]; then
    while IFS= read -r repo; do
        dest=${TARGET}/github/${repo}
        if [ ! -e "${dest}" ]; then
          continue;
        fi
        mv "${temp}/gits/${repo}" "${dest}/.git"
    done < "${repos}"
fi
