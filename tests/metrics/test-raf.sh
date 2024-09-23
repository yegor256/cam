#!/usr/bin/env bash
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

temp=$1
stdout=$2

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  touch "temp_file"
  mkdir -p "${tmp}"
  "${LOCAL}/metrics/raf.sh" "temp_file" "${temp}/stdout"
  grep "RAF 0 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Didn't fail in non-git directory"

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  rm -rf ./*
  rm -rf .git
  git init --quiet .
  git config user.email 'foo@example.com'
  git config user.name 'Foo'
  file1="temp_file1"
  file2="temp_file2"
  file3="temp_file3"
  touch "${file1}"
  git add "${file1}"
  git config commit.gpgsign false
  GIT_COMMITTER_DATE="$(date -d "100 minutes ago")" git commit --date "100 minutes ago" --quiet -m "first"
  "${LOCAL}/metrics/raf.sh" "${file1}" ./log1
  touch "${file2}"
  git add "${file2}"
  GIT_COMMITTER_DATE="$(date -d "50 minutes ago")" git commit --date "50 minutes ago" --quiet -m "second"
  "${LOCAL}/metrics/raf.sh" "${file2}" ./log2
  touch "${file3}"
  git add "${file3}"
  git commit --quiet -m "third"
  "${LOCAL}/metrics/raf.sh" "${file3}" ./log3
  if ! grep "RAF 1.0" "log1"; then
    echo "The RAF metric is wrong for '${file1}' (file created first):"
    cat ./log1
    exit 1
  fi
  if ! grep "RAF 0.5" "log2"; then
    echo "The RAF metric is wrong for '${file2}' (file created exactly in the middle):"
    cat ./log2
    exit 1
  fi
  if ! grep "RAF 0.0" "log3"; then
    echo "The RAF metric is wrong for '${file3}' (file created last):"
    cat ./log3
    exit 1
  fi
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated the Relative Age of File"
