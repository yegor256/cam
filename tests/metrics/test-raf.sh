#!/usr/bin/env bash

set -e
set -o pipefail

temp=$1
stdout=$2

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  touch "temp_file"
  "${LOCAL}/metrics/raf.sh" "temp_file" "${LOCAL}/${temp}/stdout"
  grep "raf 0" "${LOCAL}/${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Didn't fail in non-git directory"

{
  cd "${temp}"
  rm -rf ./*
  rm -rf .git
  git init --quiet .
  git config user.email 'foo@example.com'
  git config user.name 'Foo'
  file="temp_file"
  file2="temp_file1"
  touch "${file}"
  git add "${file}"
  git config commit.gpgsign false
  git commit --quiet -m "first"
  "${LOCAL}/metrics/raf.sh" "${file}" "t1"
  sleep 1
  touch "${file2}"
  git add "${file2}"
  git commit --quiet -m "second"
  "${LOCAL}/metrics/raf.sh" "${file2}" "t2"
  sleep 1
  "${LOCAL}/metrics/raf.sh" "${file2}" "t3"
  grep "raf 0.0" "t1" # File is created with repo
  grep "raf 1.0" "t2" # File a second after repo
  grep "raf 0.5" "t3" # File created exactly in the middle
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated the Relative Age of File"