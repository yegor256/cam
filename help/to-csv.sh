#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

# Take the STDIN and send it to STDOUT, while making it
# suitable for CSV: replacing commas.

data=$(cat)
printf '%s' "${data}" | sed 's/,/\\,/g'
