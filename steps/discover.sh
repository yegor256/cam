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

details=${TARGET}/temp/repo-details.tex
mkdir -p "$(dirname "${details}")"

csv=${TARGET}/repositories.csv
echo "" > "${details}"
if [ -e "${csv}" ]; then
  echo "The list of repos is already here: ${csv}"
  if [ -n "${REPO}" ]; then
    echo "Before using REPO environment variable you should delete the ${csv} file ($(wc -l < "${csv}" | xargs) lines)"
    clones=${TARGET}/github
    if [ -e "${clones}" ]; then
      printf "ATTENTION: If you do this (delete the CSV file), and then run 'make' again, all cloned repositories in the '%s' directory will be deleted (%d directories). " \
        "${TARGET}/github/" "$(find "${clones}" -type d -depth 2 | wc -l | xargs)"
      printf "After this, the dataset will not be suitable for further analysis! "
      printf "Think twice! If you just want to analyze one repository, do it in a different directory.\n"
    fi
    exit 1
  fi
elif [ -n "${REPO}" ]; then
  echo "Using one repo: ${REPO}"
  echo -e "repo,\n${REPO}," > "${csv}"
elif [ -z "${REPOS}" ] || [ ! -e "${REPOS}" ]; then
  echo "Using discover-repos.rb..."
  declare -a args=( \
    "--token=${TOKEN}" \
    "--total=${TOTAL}" \
    "--csv=${csv}" \
    "--tex=${TARGET}/temp/repo-details.tex" \
    "--pause=2" \
    "--min-stars=400" \
    "--max-stars=10000" \
  )
  if [ -n "${CAMTESTS}" ]; then
    args+=('--dry' '--pause=0')
  fi
  "${LOCAL}/help/assert-tool.sh" ruby -v
  ruby "${LOCAL}/steps/discover-repos.rb" "${args[@]}"
  nosamples=${TARGET}/no-samples.csv
  declare -a fargs=( \
    "--repositories=${csv}" \
    "--out=${nosamples}" \
    "--model=transformer"
  )
  samples-filter filter "${fargs[@]}"
  rm "${csv}"
  mv "${nosamples}" "${csv}"
else
  echo "Using the list of repositories from the '${REPOS}' file (defined by the REPOS environment variable)..."
  cat "${REPOS}" > "${csv}"
fi

cat "${csv}"
