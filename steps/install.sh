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

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  linux=yes
fi
set -x

if [ -n "${linux}" ]; then
  SUDO=
else
  SUDO=sudo
fi

if [ -n "${linux}" ]; then
  if [ ! "$(id -u)" = 0 ]; then
    echo "You should run it as root: 'sudo make install'"
    exit 1
  fi
fi

if [ -n "${linux}" ]; then
  apt-get -y update
  apt-get install -y coreutils
fi

function install_package() {
    local PACKAGE=$1
    if ! eval "$PACKAGE" --version >/dev/null 2>&1; then
        if [ -n "${linux}" ]; then
            apt-get install -y "$PACKAGE"
        else
            echo "Install '$PACKAGE' somehow"
            exit 1
        fi
    fi
}

install_package parallel
install_package bc
install_package cloc
install_package jq
install_package shellcheck
install_package aspell
install_package xmlstarlet
install_package gawk

if ! pdftotext -v >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    apt-get install -y xpdf
  else
    echo "Install 'poppler' somehow"
    exit 1
  fi
fi

if ! python3 --version >/dev/null 2>&1; then
  echo "Install 'python3' somehow"
  exit 1
fi
if ! pip --version >/dev/null 2>&1; then
  echo "Install 'pip' somehow"
  exit 1
fi
$SUDO python3 -m pip install --upgrade pip
$SUDO python3 -m pip install -r "${LOCAL}/requirements.txt"

if ! ruby -v >/dev/null 2>&1; then
  echo "Install 'ruby' somehow"
  exit 1
fi
if ! gem -v >/dev/null 2>&1; then
  echo "Install 'gem' somehow"
  exit 1
fi
gem install --no-document rubocop -v 1.56.3
gem install --no-document octokit -v 4.21.0
gem install --no-document slop -v 4.9.1

if ! pygmentize -V >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    apt-get install -y python3-pygments
  else
    echo "Install 'python3-pygments' somehow"
    exit 1
  fi
fi

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

if ! javac -version >/dev/null 2>&1; then
  echo "Install 'javac' somehow"
  exit 1
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

if ! tlmgr --version >/dev/null 2>&1; then
  if [ -n "${linux}" ]; then
    year=$(date +%Y)
    bin=/usr/local/texlive/${year}/bin
    if [ ! -d "${bin}" ]; then
      wget --quiet https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
      zcat < install-tl-unx.tar.gz | tar xf -
      rm install-tl-unx.tar.gz
      cd install-tl-"${year}"*
      perl ./install-tl --scheme=e --no-interaction
      cd ..
      rm -r install-tl-"${year}"*
      tl=$(ls -d "${bin}"/*/)
      export PATH="${PATH}:${tl}"
    else
      echo "The directory with TeXLive does exist, but 'tlmgr' doesn't run, why?"
      exit 1
    fi
  else
    echo "Install 'TeXLive' somehow"
    exit 1
  fi
fi

if [ ! -e "${HOME}/texmf" ]; then
  $SUDO tlmgr init-usertree
fi
$SUDO tlmgr option repository ctan
$SUDO tlmgr --verify-repo=none update --self
root=$(dirname "$0")
packages=()
while IFS= read -r p; do
  packages+=( "${p}" )
done < <( cut -d' ' -f2 "${root}/../DEPENDS.txt" | uniq )
$SUDO tlmgr --verify-repo=none install "${packages[@]}"
$SUDO tlmgr --verify-repo=none update --no-auto-remove "${packages[@]}" || echo 'Failed to update'

set +x
echo "All dependencies are installed and up to date! Now you can run 'make' and build the dataset."
