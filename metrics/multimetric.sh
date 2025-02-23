#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
HSD $(echo "${body}" | jq '.halstead_difficulty' | "${LOCAL}/help/float.sh") \textbf{Halstead Difficulty}: This metric measures the difficulty of understanding a program based on the number of distinct operators and operands used. A higher Halstead Difficulty indicates that the program is harder to understand and maintain due to its complexity. It is calculated using the formula: \( \text{Difficulty} = \frac{(n_1)}{2} \times \frac{(n_2)}{n_2} \), where \( n_1 \) is the number of distinct operators, and \( n_2 \) is the number of distinct operands. See details: \href{https://en.wikipedia.org/wiki/Halstead_complexity_measures#Difficulty}{Halstead Difficulty on Wikipedia}
HSE $(echo "${body}" | jq '.halstead_effort' | "${LOCAL}/help/float.sh") \textbf{Halstead Effort}: This metric estimates the total effort required to understand and implement a program based on its size and complexity. The higher the effort, the more difficult the program is to maintain and modify. Halstead Effort is calculated as \( \text{Effort} = \text{Difficulty} \times \text{Volume} \), where Difficulty is the Halstead Difficulty, and Volume represents the size of the program. A higher value reflects more effort required for comprehension and modification. See details: \href{https://en.wikipedia.org/wiki/Halstead_complexity_measures#Effort}{Halstead Effort on Wikipedia}
HSV $(echo "${body}" | jq '.halstead_volume' | "${LOCAL}/help/float.sh") \textbf{Halstead Volume}: This metric measures the size of a program based on its operators and operands. Halstead Volume estimates the amount of mental effort required to understand the code. It is calculated as \( \text{Volume} = (n_1 + n_2) \times \log_2 (n_1 + n_2) \), where \( n_1 \) and \( n_2 \) are the number of distinct operators and operands, respectively. A larger volume indicates a larger and potentially more complex program. See details: \href{https://en.wikipedia.org/wiki/Halstead_complexity_measures#Volume}{Halstead Volume on Wikipedia}
MIdx $(echo "${body}" | jq '.maintainability_index' | "${LOCAL}/help/float.sh") \textbf{Maintainability Index}: This metric is used to assess the maintainability of a software system based on its complexity and readability. It is a composite measure that takes into account various code metrics such as lines of code, cyclomatic complexity, and Halstead volume. The higher the Maintainability Index, the more maintainable the code is considered to be. The index is typically calculated using the formula:
FOut $(echo "${body}" | jq '.fanout_external' | "${LOCAL}/help/float.sh") \textbf{Fan-Out}: This metric measures the extent to which a class or module depends on external components or other classes. A higher Fan-Out indicates that the class has a greater number of dependencies, which can lead to increased complexity and potential difficulties in maintaining the system. See details: \href{https://en.wikipedia.org/wiki/Fan-out_(software)}{Fan-Out on Wikipedia}
EOT
