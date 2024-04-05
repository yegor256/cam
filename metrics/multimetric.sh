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

java=$1
output=$2

json=$(multimetric "${java}")
body=$(echo "${json}" | jq '.overall')
temp="${TARGET}/temp/multimetric.json"
mkdir -p "$(dirname "${temp}")"
echo "${body}" > "${temp}"
cat <<EOT> "${output}"
HSD $(echo "${body}" | jq '.halstead_difficulty' | "${LOCAL}/help/float.sh") Halstead Difficulty~\citep{halstead1977elements}
HSE $(echo "${body}" | jq '.halstead_effort' | "${LOCAL}/help/float.sh") Halstead Effort~\citep{halstead1977elements}
HSV $(echo "${body}" | jq '.halstead_volume' | "${LOCAL}/help/float.sh") Halstead Volume~\citep{halstead1977elements}
MIdx $(echo "${body}" | jq '.maintainability_index' | "${LOCAL}/help/float.sh") Maintainability Index~\citep{coleman1994}
FOut $(echo "${body}" | jq '.fanout_external' | "${LOCAL}/help/float.sh") \href{https://en.wikipedia.org/wiki/Fan-out_(software)}{Fan-Out}
EOT
