#!/usr/bin/env bash
# shellcheck disable=SC2317
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

# ENABLE THIS TESTS RIGHT AFTER IMPLEMENTING irca.sh VIA REMOVING `exit 0`
exit 0

temp=$1
stdout=$2

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  mkdir -p "${LOCAL}/${temp}"
  touch "${LOCAL}/${temp}/file.java"
  "${LOCAL}/metrics/irca.sh" "${LOCAL}/${temp}/file.java" "${LOCAL}/${temp}/stdout"
  grep "Provided non-git repo" "${LOCAL}/${temp}/stdout"
} >"${stdout}" 2>&1
echo "👍🏻 Didn't fail in non-git directory"

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  rm -rf ./*
  rm -rf .git
  git init --quiet .
  git config user.email 'foo@example.com'
  git config user.name 'Foo'
  file1="one.java"
  "${LOCAL}/metrics/irca.sh" "./${file1}" "t0"
  grep "File does not exist" "t0" # The given file does not exist
} >"${stdout}" 2>&1
echo "👍🏻 Didn't fail in repo without given file"

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  rm -rf ./*
  rm -rf .git
  git init --quiet .
  git config user.email 'foo@example.com'
  git config user.name 'Foo'
  file1="one.java"
  touch "${file1}"
  "${LOCAL}/metrics/irca.sh" "./${file1}" "t0"
  grep "No commits yet in repo" "t0" # There are no commits in repo with given file
} >"${stdout}" 2>&1
echo "👍🏻 Didn't fail in repo without commits"

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  rm -rf ./*
  rm -rf .git
  git init --quiet .
  git config user.email 'foo1@example.com'
  git config user.name 'Foo1'
  file1="one.java"
  touch "${file1}"
  git add "${file1}"
  git config commit.gpgsign false
  git commit --quiet -m "added first file"
  "${LOCAL}/metrics/irca.sh" "./${file1}" "t1"
  grep "irca 1 " "t1" # There is only committer in repo

  git config user.email 'foo2@example.com'
  git config user.name 'Foo2'
  file2="two.java"
  touch "${file2}"
  git add "${file2}"
  git commit --quiet -m "added second file"
  "${LOCAL}/metrics/irca.sh" "./${file2}" "t2"
  grep "irca 0.5 " "t2" # There are two committers in repo and one for the given file

  git config user.email 'foo3@example.com'
  git config user.name 'Foo3'
  file3="three.java"
  touch "${file3}"
  git add "${file3}"
  git commit --quiet -m "added third file"
  "${LOCAL}/metrics/irca.sh" "./${file3}" "t3"
  grep "irca 0.33 " "t3" # There are three committers in repo and one for the given file
} >"${stdout}" 2>&1
echo "👍🏻 Correctly calculated the IRLoC (Impact Ratio by Lines of Code)"
