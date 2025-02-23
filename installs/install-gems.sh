#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

"${LOCAL}/help/assert-tool.sh" ruby -v
"${LOCAL}/help/assert-tool.sh" gem -v

if ! gem list -i rubocop; then
    gem install --no-document rubocop -v 1.56.3
fi

if ! gem list -i octokit; then
    gem install --no-document octokit -v 4.21.0
fi

if ! gem list -i slop; then
    gem install --no-document slop -v 4.9.1
fi
