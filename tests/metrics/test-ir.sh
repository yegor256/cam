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
