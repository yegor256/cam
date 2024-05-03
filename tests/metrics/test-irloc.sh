#!/usr/bin/env bash
# shellcheck disable=SC2317
# The MIT License (MIT)
#
# Copyright (c) 2021-2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
set -e
set -o pipefail

# TODO: #281 ENABLE THIS TESTS VIA REMOVING `exit 0` AND REMOVE `shellcheck disable=SC2317` on the top RIGHT AFTER IMPLEMENTING irloc.sh
exit 0

temp=$1
stdout=$2

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  mkdir -p "${LOCAL}/${temp}"
  touch "${LOCAL}/${temp}/file.java"
  if ! "${LOCAL}/metrics/irloc.sh" "${LOCAL}/${temp}/file.java" "${LOCAL}/${temp}/stdout"
  then
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
  file1="one.java"
  if ! "${LOCAL}/metrics/irloc.sh" "./${file1}" "t0"
  then
    exit 1
  fi
} >"${stdout}" 2>&1
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
  "${LOCAL}/metrics/irloc.sh" "./${file1}" "t0"
  grep "IRLoC 0" "t0" # There are no commits in repo with given file
} >"${stdout}" 2>&1
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
  git commit --quiet -m "first file"
  "${LOCAL}/metrics/irloc.sh" "./${file1}" "t0"
  grep "IRLoC 0" "t0" # There are only empty files committed in the repo
} >"${stdout}" 2>&1
echo "👍🏻 Didn't fail in repo with zero lines of code"

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  rm -rf ./*
  rm -rf .git
  git init --quiet .
  git config user.email 'foo@example.com'
  git config user.name 'Foo'
  file1="one.java"
  echo "line" >"${file1}"
  git add "${file1}"
  git config commit.gpgsign false
  git commit --quiet -m "first line"
  "${LOCAL}/metrics/irloc.sh" "./${file1}" "t1"
  grep "IRLoC 1 " "t1" # There is only line in repo and it is inside the given file

  file2="two.java"
  echo "line" >"${file2}"
  git add "${file2}"
  git commit --quiet -m "second line"
  "${LOCAL}/metrics/irloc.sh" "./${file2}" "t2"
  grep "IRLoC 0.5 " "t2" # There are two lines in repo and one for the given file

  printf "line\nline" >>"file.txt"
  git add "${file2}"
  git commit --quiet -m "two more lines"
  "${LOCAL}/metrics/irloc.sh" "./${file2}" "t3"
  grep "IRLoC 0.75 " "t3" # There are four lines in repo and three for the given file
} >"${stdout}" 2>&1
echo "👍🏻 Correctly calculated the IRLoC (Impact Ratio by Lines of Code)"
