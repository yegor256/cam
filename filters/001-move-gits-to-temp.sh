#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

temp=$2

if [ ! -e "${TARGET}/github" ]; then
  exit;
fi

list=${temp}/git-to-move.txt
find "${TARGET}/github" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'realpath --relative-to="${1}" "$2"' _ "${TARGET}/github" {} \; > "${list}"

gits=${temp}/gits
mkdir -p "${gits}"

if [ -s "${list}" ]; then
    while IFS= read -r repo; do
        src=${TARGET}/github/${repo}/.git
        if [ ! -e "${src}" ]; then
          continue;
        fi
        mkdir -p "$(dirname "${gits}/${repo}")"
        mv "${src}" "${gits}/${repo}"
    done < "${list}"
fi
