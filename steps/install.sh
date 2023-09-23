#!/usr/bin/env bash
# MIT License
#
# Copyright (c) 2021-2023 Yegor Bugayenko
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

set -x
set -e
set -o pipefail

apt-get -y update
apt-get install -y coreutils

if ! bc -v; then
  apt-get install -y bc
fi

if ! cloc --version; then
  apt-get install -y cloc
fi

if ! shellcheck --version; then
  apt-get install -y shellcheck
fi

if ! aspell --version; then
  apt-get install -y aspell
fi

if ! xmlstarlet --version; then
  apt-get install -y xmlstarlet
fi

tlmgr --verify-repo=none update --self
declare -a packages=(href-ul huawei ffcode latexmk fmtcount trimspaces \
  libertine paralist makecell footmisc currfile enumitem wrapfig \
  lastpage biblatex titling svg catchfile transparent textpos fvextra \
  xstring framed environ iexec anyfontsize changepage titlesec upquote hyperxmp biber)
tlmgr --verify-repo=none install "${packages[@]}"
tlmgr --verify-repo=none update "${packages[@]}"

if ! pygmentize -V; then
  apt-get install -y python3-pygments
fi

python3 -m pip install -r "${LOCAL}/requirements.txt"

gem install --no-document rubocop -v 1.56.3
gem install --no-document octokit -v 4.21.0
gem install --no-document slop -v 4.9.1

if ! inkscape --version; then
  add-apt-repository -y ppa:inkscape.dev/stable && \
    apt-get update -y && \
    apt-get install -y inkscape
fi

if ! pmd pmd --version; then
  pmd_version=6.55.0
  cd /usr/local && \
    wget --quiet https://github.com/pmd/pmd/releases/download/pmd_releases%2F6.55.0/pmd-bin-${pmd_version}.zip && \
    unzip -qq pmd-bin-${pmd_version}.zip && \
    rm pmd-bin-${pmd_version}.zip && \
    mv pmd-bin-${pmd_version} pmd && \
    ln -s /usr/local/pmd/bin/run.sh /usr/local/bin/pmd
fi

if ! gradle --version; then
  gradle_version=7.4
  wget --quiet https://services.gradle.org/distributions/gradle-${gradle_version}-bin.zip \
      && unzip -qq gradle-${gradle_version}-bin.zip -d /opt \
      && rm gradle-${gradle_version}-bin.zip
  export GRADLE_LOCAL=/opt/gradle-${gradle_version}
  export PATH=$PATH:/opt/gradle-${gradle_version}/bin
fi

if [ ! -e "${JPEEK}" ]; then
  jpeek_version=0.32.0
  wget --quiet https://repo1.maven.org/maven2/org/jpeek/jpeek/${jpeek_version}/jpeek-${jpeek_version}-jar-with-dependencies.jar \
      && mkdir -p "$(dirname "${JPEEK}")" \
      && mv jpeek-${jpeek_version}-jar-with-dependencies.jar "${JPEEK}"
fi
