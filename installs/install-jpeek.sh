#!/usr/bin/env bash
# MIT License
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
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e
set -o pipefail

"${LOCAL}/help/assert-tool.sh" javac --version

if [ -e "${JPEEK}" ]; then
  java -jar "${JPEEK}" --help
  echo "jPeek JAR is already here: ${JPEEK}"
  exit
fi

jpeek_version=0.32.0
cd /tmp
wget --quiet https://repo1.maven.org/maven2/org/jpeek/jpeek/${jpeek_version}/jpeek-${jpeek_version}-jar-with-dependencies.jar
if "${LOCAL}/help/is-macos.sh"; then
  "${LOCAL}/help/sudo.sh" mkdir -p "$(dirname "${JPEEK}")"
  "${LOCAL}/help/sudo.sh" mv "jpeek-${jpeek_version}-jar-with-dependencies.jar" "${JPEEK}"
elif "${LOCAL}/help/is-linux.sh"; then
  mkdir -p "$(dirname "${JPEEK}")"
  mv "jpeek-${jpeek_version}-jar-with-dependencies.jar" "${JPEEK}"
fi
java -jar "${JPEEK}" --help
echo "jPeek downloaded into ${JPEEK}"
