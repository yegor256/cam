#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e
set -o pipefail

if [ -z "${LOCAL}" ]; then
  LOCAL=$(dirname "$0")/..
fi

"${LOCAL}/help/assert-tool.sh" javac --version

if gradle --version >/dev/null 2>&1; then
  gradle --version
  echo "Gradle is already installed"
  exit
fi

if [ ! -e /usr/local ]; then
  echo "The directory /usr/local must exist"
  exit 1
fi

gradle_version=7.4
cd /usr/local
wget --quiet https://services.gradle.org/distributions/gradle-${gradle_version}-bin.zip
unzip -qq gradle-${gradle_version}-bin.zip
rm gradle-${gradle_version}-bin.zip
mv gradle-${gradle_version} gradle
ln -s /usr/local/gradle/bin/gradle /usr/local/bin/gradle
echo "Gradle installed into /usr/local/gradle"
gradle --version
