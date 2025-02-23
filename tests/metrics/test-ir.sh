#!/usr/bin/env bash
# shellcheck disable=SC2317
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

# TODO: #259 ENABLE THIS TESTS RIGHT AFTER IMPLEMENTING ir.sh VIA REMOVING `exit 0` AND REMOVE `shellcheck disable=SC2317` on the top RIGHT AFTER IMPLEMENTING ir.sh
exit 0

temp=$1
stdout=$2

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  mkdir -p "${LOCAL}/${temp}"
  if ! "${LOCAL}/metrics/ir.sh" ./ "${LOCAL}/${temp}/stdout"; then
    exit 1
  fi
} >"${stdout}" 2>&1
echo "👍🏻 Failed in non-git directory"

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  rm -rf ./*
  rm -rf .git
  git init --quiet .
  git config user.email 'foo@example.com'
  git config user.name 'Foo'
  if ! "${LOCAL}/metrics/ir.sh" ./ "t0"; then
    exit 1
  fi
  file1="one.java"
  file2="two.java"
  touch "${file1}"
  git add "${file1}"
  git config commit.gpgsign false
  git commit --quiet -m "first file"
  "${LOCAL}/metrics/ir.sh" ./ "t1"
  touch "${file2}"
  git add "${file2}"
  git commit --quiet -m "second file"
  "${LOCAL}/metrics/ir.sh" ./ "t2"
  grep "IR 1" "t1"    # Single file in repo
  grep "IR 0.5 " "t2" # Two files in repo
} >"${stdout}" 2>&1
echo "👍🏻 Correctly calculated the IR (Impact Ratio)"
