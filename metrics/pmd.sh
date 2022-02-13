#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
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
tmp=$(mktemp -d)

mkdir -p "${tmp}"

cat <<EOT > "${tmp}/config.xml"
<?xml version="1.0"?>
<ruleset name="cam" xmlns="http://pmd.sourceforge.net/ruleset/2.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://pmd.sourceforge.net/ruleset/2.0.0 https://pmd.sourceforge.io/ruleset_2_0_0.xsd">
  <rule ref="category/java/design.xml/CognitiveComplexity">
    <properties>
      <property name="reportLevel" value="1" />
    </properties>
  </rule>
</ruleset>
EOT

cp "${java}" "${tmp}/foo.java"

pmd pmd -R "${tmp}/config.xml" -d "${tmp}" -format xml -failOnViolation false > "${tmp}/result.xml" 2>/dev/null

sed 's/xmlns=".*"//g' "${tmp}/result.xml" | \
  (xmllint --xpath '//violation[@rule="CognitiveComplexity"]/text()' - 2>/dev/null || echo '') | \
  sed -E "s/.*complexity of ([0-9]+).*/\1/" | \
  sed '/^[[:space:]]*$/d' | \
  ruby -e '
    a = STDIN.read.split(" ").map(&:to_i)
    sum = a.inject(&:+)
    puts "coc #{a.empty? ? 0 : sum} Total Cognitive Complexity of All Methods"
    puts "acoc #{a.empty? ? 0 : sum / a.count} Average Cognitive Complexity of a Method"
    puts "mxcoc #{a.empty? ? 0 : a.max} Max Cognitive Complexity of a Method"
    puts "mncoc #{a.empty? ? 0 : a.min} Min Cognitive Complexity of a Method"
  ' > "${output}"

rm -rf "${tmp}"

