#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex
set -o pipefail

"${LOCAL}/help/assert-tool.sh" python3 --version
"${LOCAL}/help/assert-tool.sh" pip3 --version

if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

# shellcheck source=/dev/null
source venv/bin/activate

python3 --version
pip3 --version
pip3 install -r "${LOCAL}/requirements.txt"
