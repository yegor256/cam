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

set -e
set -o pipefail

if [ ! "$(id -u)" = 0 ]; then
  echo "You should run it as root: 'sudo make install'"
  exit 1
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  linux=yes
fi
set -x

if [ -n "${linux}" ]; then
  apt-get -y update
  apt-get install -y coreutils
fi

if ! parallel --version >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    apt-get -y install parallel
  else
    echo "Install 'parallel' somehow"
    exit 1
  fi
fi

if ! bc -v >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    apt-get install -y bc
  else
    echo "Install 'GNU bc' somehow"
    exit 1
  fi
fi

if ! cloc --version >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    apt-get install -y cloc
  else
    echo "Install 'cloc' somehow"
    exit 1
  fi
fi

if ! jq --version >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    apt-get install -y jq
  else
    echo "Install 'jq' somehow"
    exit 1
  fi
fi

if ! shellcheck --version >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    apt-get install -y shellcheck
  else
    echo "Install 'shellcheck' somehow"
    exit 1
  fi
fi

if ! aspell --version >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    apt-get install -y aspell
  else
    echo "Install 'GNU aspell' somehow"
    exit 1
  fi
fi

if ! xmlstarlet --version >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    apt-get install -y xmlstarlet
  else
    echo "Install 'xmlstarlet' somehow"
    exit 1
  fi
fi

if [ ! -e "${HOME}/texmf" ]; then
  tlmgr init-usertree
fi
tlmgr option repository ctan
tlmgr --verify-repo=none update --self
declare -a packages=(href-ul huawei ffcode latexmk fmtcount trimspaces \
  libertine paralist makecell footmisc currfile enumitem wrapfig \
  lastpage biblatex titling svg catchfile transparent textpos fvextra \
  xstring framed environ iexec anyfontsize changepage titlesec upquote hyperxmp biber)
tlmgr --verify-repo=none install "${packages[@]}"
tlmgr --verify-repo=none update "${packages[@]}"

if ! pygmentize -V >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    apt-get install -y python3-pygments
  else
    echo "Install 'python3-pygments' somehow"
    exit 1
  fi
fi

python3 -m pip install -r "${LOCAL}/requirements.txt"

gem install --no-document rubocop -v 1.56.3
gem install --no-document octokit -v 4.21.0
gem install --no-document slop -v 4.9.1

if ! inkscape --version >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    add-apt-repository -y ppa:inkscape.dev/stable && \
      apt-get update -y && \
      apt-get install -y inkscape
  else
    echo "Install 'inkscape' somehow"
    exit 1
  fi
fi

if ! pmd pmd --version >/dev/null 2>&1; then
  if [ ! -e /usr/local ]; then
    echo "The directory /usr/local must exist"
    exit 1
  fi
  pmd_version=6.55.0
  cd /usr/local && \
    wget --quiet https://github.com/pmd/pmd/releases/download/pmd_releases%2F6.55.0/pmd-bin-${pmd_version}.zip && \
    unzip -qq pmd-bin-${pmd_version}.zip && \
    rm pmd-bin-${pmd_version}.zip && \
    mv pmd-bin-${pmd_version} pmd && \
    ln -s /usr/local/pmd/bin/run.sh /usr/local/bin/pmd
fi

if ! gradle --version >/dev/null 2>&1; then
  if [ ! -e /usr/local ]; then
    echo "The directory /usr/local must exist"
    exit 1
  fi
  gradle_version=7.4
  cd /usr/local && \
    wget --quiet https://services.gradle.org/distributions/gradle-${gradle_version}-bin.zip && \
    unzip -qq gradle-${gradle_version}-bin.zip && \
    rm gradle-${gradle_version}-bin.zip && \
    mv gradle-${gradle_version} gradle && \
  export GRADLE_LOCAL=/usr/local/gradle
  export PATH=$PATH:/usr/local/gradle/bin
fi

if [ ! -e "${JPEEK}" ]; then
  jpeek_version=0.32.0
  cd /tmp && \
    wget --quiet https://repo1.maven.org/maven2/org/jpeek/jpeek/${jpeek_version}/jpeek-${jpeek_version}-jar-with-dependencies.jar && \
    mkdir -p "$(dirname "${JPEEK}")" && \
    mv "jpeek-${jpeek_version}-jar-with-dependencies.jar" "${JPEEK}"
fi

set +x
echo "All dependencies are installed and up to date! Now you can run 'make' and build the dataset."
