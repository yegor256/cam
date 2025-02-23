#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

if ! tlmgr --version >/dev/null 2>&1; then
  PATH=$PATH:$("${LOCAL}/help/texlive-bin.sh")
  export PATH
fi

if [ -z "${LOCAL_METRICS}" ]; then
  LOCAL_METRICS=${LOCAL}/metrics
fi

list=${TARGET}/temp/list-of-metrics.tex
rm -f "${list}"
touch "${list}"

java=${TARGET}/temp/Foo.java
if [ -f "venv/bin/activate" ]; then
  # shellcheck source=venv/bin/activate disable=SC1091
  . venv/bin/activate
else
  echo "Error: venv/bin/activate not found. Please make sure the virtual environment is set up."
  exit 1
fi
mkdir -p "$(dirname "${java}")"
find "${LOCAL_METRICS}" -type f -exec test -x {} \; -exec basename {} \; | while IFS= read -r m; do
    echo "class Foo {}" > "${java}"
    metric=${TARGET}/temp/Foo.${m}.m
    rm -f "${metric}"
    "${LOCAL_METRICS}/${m}" "${java}" "${metric}"
    awk '{ s= "\\item\\ff{" $1 "}: "; for (i = 3; i <= NF; i++) s = s $i " "; print s; }' < "${metric}" >> "${list}"
    echo "$(wc -l < "${metric}" | xargs) metrics from ${m}"
done

if [ ! -s "${list}" ]; then
    echo "No metric generating files found, probably an internal error"
    exit 1
fi

st_list=${TARGET}/temp/structured-list-of-metrics.tex
rm -f "${st_list}"
touch "${st_list}"

groups=()
while IFS='' read -r line; do
    groups+=("$line")
done < <(grep -oE '\[.*\]' "${list}" | sed 's/[][]//g' | sort -u || : ; echo "Ungrouped metrics")
for idx in "${!groups[@]}"; do
    if [ "$idx" -eq $(( ${#groups[@]} - 1 )) ]; then
        group_metrics=$(grep -oE "^[^[]*$" "${list}" || :)
    else
        group_metrics=$(grep -oE ".*\b${groups[$idx]}\b.*" "${list}" || :)
    fi
    if [[ $(printf "%s\n" "${group_metrics[@]}" | grep -c "item") -eq 0 ]]; then
      continue;
    fi
    printf "\\item %s\n" "${groups[$idx]}" >> "${st_list}"
    printf "\\\\begin{itemize}\n" >> "${st_list}"
    while IFS= read -r metric; do
        clean_metric="${metric//\[*\]/}"
        printf "\t%s\n" "${clean_metric}" >> "${st_list}"
    done <<< "$group_metrics"
    printf "\\\\end{itemize}\n" >> "${st_list}"
done
cp "${list}" "${list}.unstructured"
mv "${st_list}" "${list}"

# Create the aggregation table LaTeX file
aggregation_table=${TARGET}/temp/aggregation_table.tex
echo > "${aggregation_table}"

# LaTeX escape function to handle special characters
latex_escape() {
  echo "$1" | sed 's/&/\\&/g; s/%/\\%/g; s/_/\\_/g; s/\$/\\\$/g; s/#{}/\\{\\}/g; s/\^/\\^/g; s/~/{\~}/g; s/\\/\\\\/g'
}

{
  printf "\onecolumn\n"
  printf "\\centering\n"
  printf "\\\\begin{longtable}{|l|c|c|c|}\n"
  printf "\\hline\n"
  printf "Metric & 90th Percentile & Mean & Median \\\\\\\\\\\\\ \n"
  printf "\\hline\n"
} >> "${aggregation_table}"

shopt -s nullglob
files=("${TARGET}/data/aggregation/"*.csv)
shopt -u nullglob

if [ "${#files[@]}" -gt 0 ]; then
  for file in "${files[@]}"; do
      metric=$(basename "${file}" | cut -d '.' -f 1)
      value=$(<"${file}")
      if [[ "${file}" =~ \.90th_percentile\.csv$ ]]; then
          percentile="${value}"
          mean=""
          median=""
      elif [[ "${file}" =~ \.mean\.csv$ ]]; then
          mean="${value}"
      elif [[ "${file}" =~ \.median\.csv$ ]]; then
          median="${value}"
      fi
      percentile=$(latex_escape "${percentile}")
      mean=$(latex_escape "${mean}")
      median=$(latex_escape "${median}")
      if [[ -n "${percentile}" && -n "${mean}" && -n "${median}" ]]; then
          printf "%s & %s & %s & %s \\\\\\\\\\\\\ \n" "${metric}" "${percentile}" "${mean}" "${median}" >> "${aggregation_table}"
      fi
  done
fi

# Close the LaTeX table
printf "\\hline\n" >> "${aggregation_table}"
printf "\\\\end{longtable}\n" >> "${aggregation_table}"

printf "Aggregation table generated in %s\n" "${aggregation_table}"

# It's important to make sure the path is absolute, for LaTeX
t=$(realpath "${TARGET}")

tmp=${t}/temp/pdf-report
if [ -e "${tmp}" ]; then
    echo "Temporary directory for PDF report building already exists: '${tmp}'"
    latexmk -cd -C "${tmp}/report.tex"
    cp -r "${LOCAL}"/tex/ "${tmp}"
else
    mkdir -p "$(dirname "${tmp}")"
    cp -r "${LOCAL}/tex" "${tmp}"
    echo "Temporary directory for PDF report created: '${tmp}'"
fi

pdf=${tmp}/report.pdf
if [ -e "${pdf}" ]; then
    echo "The PDF report already exists: '${pdf}'"
    exit
fi

dest=${t}/report.pdf
if ! TARGET="${t}" latexmk -pdf -r "${tmp}/.latexmkrc" -quiet -cd "${tmp}/report.tex"; then
    log=${tmp}/report.log
    if [ -e "${log}" ]; then
        cat "${log}"
        echo "Failed to generate PDF report with LaTeX from ${tmp}/report.tex, see the log above (${log})"
    else
        echo "Failed to generate PDF report with LaTeX, there is no log file visible (${log})"
    fi
    exit 1
fi
cp "${pdf}" "${dest}"

echo "PDF report generated in ${dest} ($(du -k "${dest}" | cut -f1) Kb)"
