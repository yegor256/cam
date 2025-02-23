#!/usr/bin/env bash
# shellcheck disable=SC2317
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

# TODO: #279 ENABLE THIS TESTS VIA REMOVING `exit 0` AND REMOVE `shellcheck disable=SC2317` on the top RIGHT AFTER IMPLEMENTING irc.sh
exit 0

temp=$1
stdout=$2

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  mkdir -p "${LOCAL}/${temp}"
  touch "${LOCAL}/${temp}/file.java"
  if ! "${LOCAL}/metrics/irc.sh" "${LOCAL}/${temp}/file.java" "${LOCAL}/${temp}/stdout"
  then
    exit 1
  fi
} > "${stdout}" 2>&1
echo "👍🏻 Failed in non-git directory"

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  rm -rf ./*
  rm -rf .git
  git init --quiet .
  git config user.email 'foo@example.com'
  git config user.name 'Foo'
  file1="one.java"
  if ! "${LOCAL}/metrics/irc.sh" "./${file1}"  "t0"
  then
    exit 1
  fi
} > "${stdout}" 2>&1
echo "👍🏻 Failed in repo without given file"

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
  "${LOCAL}/metrics/irc.sh" "./${file1}" "t0"
  grep "IRC 0" "t0" # There are no commits in repo with given file
} > "${stdout}" 2>&1
echo "👍🏻 Didn't fail in repo without commits"

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
  git add "${file1}"
  git config commit.gpgsign false
  git commit --quiet -m "first file"
  "${LOCAL}/metrics/irc.sh" "./${file1}" "t2"
  grep "irc 1 " "t2" # There is only commit in repo and it is for the given file

  file2="two.java"
  touch "${file2}"
  git add "${file2}"
  git commit --quiet -m "second file"
  "${LOCAL}/metrics/irc.sh" "./${file2}" "t3"
  grep "irc 0.5 " "t3" # There are two commits in repo and one for the given file
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated the IRC (Impact Ratio by Commits)"
