#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

stdout=$2
{
    export LOCAL_METRICS="${TARGET}/calculators with spaces"
    mkdir -p "${LOCAL_METRICS}/nested" "${TARGET}/bin"
    cat > "${LOCAL_METRICS}/nested/fixture.sh" <<'CALCULATOR'
#!/usr/bin/env bash
set -e -o pipefail
cat > "$2" <<'RECORDS'
One 0 [Group] \textbf{A "quoted", label}~\citep{reference}
Two 1 \( \text{Difficulty} = \frac{(n_1)}{2} \times n_2 \) \href{https://example.com}{Details}
Three 0
RECORDS
CALCULATOR
    chmod +x "${LOCAL_METRICS}/nested/fixture.sh"
    "${LOCAL}/steps/metrics.sh" > "${TARGET}/console.txt"
    grep -Fx 'One: [Group] A "quoted", label' "${TARGET}/console.txt"
    grep -Fx 'Two: Difficulty = ((n_1))/(2) * n_2 Details' "${TARGET}/console.txt"
    grep -Fx 'Three: ' "${TARGET}/console.txt"
    grep -Fx 'Total metrics: 3' "${TARGET}/console.txt"
    cp "${TARGET}/metrics.csv" "${TARGET}/expected.csv"

    # Exercise the report consumer without requiring a TeX installation.
    for tool in tlmgr latexmk; do
        printf '#!/usr/bin/env bash\nexit 0\n' > "${TARGET}/bin/${tool}"
        chmod +x "${TARGET}/bin/${tool}"
    done
    mkdir -p "${TARGET}/temp/pdf-report"
    touch "${TARGET}/temp/pdf-report/report.pdf"
    PATH="${TARGET}/bin:${PATH}" "${LOCAL}/steps/report.sh"
    cmp "${TARGET}/expected.csv" "${TARGET}/metrics.csv"
    grep -Fx '\item\ff{One}: [Group] \textbf{A "quoted", label}~\citep{reference}' \
        "${TARGET}/temp/list-of-metrics.tex.unstructured"
    grep -F '\item Group' "${TARGET}/temp/list-of-metrics.tex"

    mkdir -p "${TARGET}/empty"
    if LOCAL_METRICS="${TARGET}/empty" "${LOCAL}/steps/metrics.sh"; then
        echo 'An empty calculator directory must fail'
        exit 1
    fi
    printf '#!/usr/bin/env bash\nexit 1\n' > "${LOCAL_METRICS}/failure.sh"
    chmod +x "${LOCAL_METRICS}/failure.sh"
    if "${LOCAL}/steps/metrics.sh"; then
        echo 'A failing calculator must fail the command'
        exit 1
    fi
} > "${stdout}" 2>&1
echo 'Metric listing and report share a CSV catalog and preserve descriptions'
