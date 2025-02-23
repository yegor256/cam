#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

start=$(date +%s%N)

name=cam-$(date +%Y-%m-%d)

zip=${TARGET}/temp/${name}.zip
mkdir -p "$(dirname "${zip}")"
zip=$(readlink -f "$(dirname "${zip}")")/$(basename "${zip}")

if [ -e "${zip}" ]; then
    echo "Zip archive already exists: ${zip}"
    exit
fi

cam_repo_target_dir="${TARGET}/cam-sources"

if [ ! -d "${cam_repo_target_dir}" ]; then
    git clone --depth 1 https://github.com/yegor256/cam.git "${cam_repo_target_dir}"
    rm -rf "${cam_repo_target_dir}/.git"
fi

if [ -e "${TARGET}/github" ]; then
    echo "Deleting .git directories (may take some time) ..."
    find "${TARGET}/github" -maxdepth 3 -mindepth 3 -type d -name '.git' -exec rm -rf {} \;
fi

echo "Archiving the data into ${zip} (may take some time) ..."

zip -qq -x "${TARGET}/temp/*" -x "${TARGET}/measurements/*" -r "${zip}" "${TARGET}"

mv "${zip}" "${TARGET}"

echo "ZIP archive created at ${zip} ($(du -k "${TARGET}/${name}.zip" | cut -f1) Kb)$("${LOCAL}/help/tdiff.sh" "${start}")"

echo "Lines in repositories.csv: $(wc -l "${TARGET}/repositories.csv" | xargs)"
echo ".java files in github/: $(find "${TARGET}/github" -name '*.java' -type f -print | wc -l | xargs)"
echo "Lines in data/all.csv: $(wc -l "${TARGET}/data/all.csv" | xargs)"
echo ".csv files in data/: $(find "${TARGET}/data" -name '*.csv' -type f -print | wc -l | xargs)"
