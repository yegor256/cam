#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

cffconvert --validate

mypy --strict "${LOCAL}/" --exclude "${TARGET}/.*"

flake8 --max-line-length=140 --exclude venv "${LOCAL}/"

export PYTHONPATH="${PYTHONPATH}:${LOCAL}/pylint_plugins/"

find "${LOCAL}" -type f -name '*.py' -not -path "${LOCAL}/venv/**" -not -path "${TARGET}/**" -print0 | xargs -0 -n1 pylint --enable-all-extensions --load-plugins=custom_checkers \
    --disable=empty-comment \
    --disable=missing-module-docstring \
    --disable=invalid-name \
    --disable=too-many-try-statements \
    --disable=broad-exception-caught \
    --disable=magic-value-comparison \
    --disable=line-too-long \
    --disable=confusing-consecutive-elif \
    --disable=use-set-for-membership \
    --disable=duplicate-code

rubocop

if ! bibcop --version >/dev/null 2>&1; then
  PATH=$PATH:$("${LOCAL}/help/texlive-bin.sh")
  export PATH
fi
bibcop tex/report.bib

while IFS= read -r sh; do
    shellcheck --shell=bash --severity=style "${sh}"
    echo "${sh}: shellcheck OK"
done < <(find "$(realpath "${LOCAL}")" -name '*.sh' -type f -not -path "$(realpath "${TARGET}")/**" -not -path "$(realpath "${LOCAL}")/venv/**")

header="Copyright (c) 2021-$(date +%Y) Yegor Bugayenko"
failed="false"
for mask in *.sh *.py *.rb *.yml *.java Makefile; do
    while IFS= read -r file; do
        if ! grep -q "$header" "$file"; then
            failed="true"
            echo "⚠️  Copyright not found in file: $file"
        fi
    done < <(find "$(realpath "${LOCAL}")" -type f -name "${mask}" \
        -not -path "$(realpath "${TARGET}")/**" \
        -not -path "$(realpath "${LOCAL}")/fixtures/filters/unparseable/**" \
        -not -path "$(realpath "${LOCAL}")/test-zone/**" \
        -not -path "$(realpath "${LOCAL}")/venv/**")
done
if [[ "${failed}" = "true" ]]; then
  exit;
fi
