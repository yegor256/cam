#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

temp=$1
stdout=$2

python3 - "${LOCAL}" "${temp}" > "${stdout}" 2>&1 <<'PY'
import json
from pathlib import Path
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

local, temp = map(Path, sys.argv[1:])
cases = json.loads((local / 'tests/metrics/cc-cases.json').read_text())
inputs = temp / 'java'
inputs.mkdir(exist_ok=True)
for case in cases:
    (inputs / (case['name'] + '.java')).write_text(case['source'])
rules = temp / 'rules.xml'
rules.write_text('''<?xml version="1.0"?>
<ruleset name="baseline" xmlns="http://pmd.sourceforge.net/ruleset/2.0.0">
  <description>Cognitive Complexity baseline</description>
  <rule ref="category/java/design.xml/CognitiveComplexity">
    <properties><property name="reportLevel" value="1" /></properties>
  </rule>
</ruleset>''')
report = subprocess.run(['pmd', 'check', '-R', str(rules), '-d', str(inputs),
                         '--format', 'xml', '--no-fail-on-violation'],
                        check=True, capture_output=True, text=True)
root = ET.fromstring(report.stdout)
assert not root.findall('.//{*}error'), report.stdout
assert not root.findall('.//{*}configerror'), report.stdout
observed = {}
for file in root.findall('{*}file'):
    observed[Path(file.attrib['name']).stem] = sum(
        int(re.search(r'complexity of (\d+)', violation.text).group(1))
        for violation in file.findall('{*}violation'))
for case in cases:
    name, expected = case['name'], case['expected']
    assert observed.get(name, 0) == case['pmd'], (name, 'PMD baseline changed', observed.get(name, 0), case['pmd'])
    output = temp / (name + '.txt')
    # Simulate the PMD rows already present: CoCoJ must not replace them.
    output.write_text('CoCo 999 PMD sentinel\n')
    subprocess.run([str(local / 'metrics/cc.py'), str(inputs / (name + '.java')), str(output)], check=True)
    rows = output.read_text().splitlines()
    assert rows[0] == 'CoCo 999 PMD sentinel', rows
    assert len(rows) == 2 and rows[1].startswith(f'CoCoJ {expected} '), (name, expected, rows)
    print(name, expected)
usage = subprocess.run([str(local / 'metrics/cc.py')], capture_output=True, text=True)
assert usage.returncode != 0 and 'cc.py' in usage.stdout, usage
for source in ('not Java', 'interface Empty {}'):
    invalid = temp / 'invalid.java'
    invalid.write_text(source)
    output = temp / 'invalid.txt'
    result = subprocess.run([str(local / 'metrics/cc.py'), str(invalid), str(output)], capture_output=True)
    assert result.returncode != 0 and not output.exists(), result
print(f"Checked {len(cases)} PMD-baselined cases, output isolation, usage and invalid input")
PY

echo "Cognitive Complexity regressions and PMD baselines verified"
