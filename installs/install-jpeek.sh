#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
