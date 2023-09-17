#!/bin/bash
# MIT License
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

apt-get -y update
apt-get install -y coreutils
apt-get install -y cloc
apt-get install -y shellcheck

gem install texsc
gem install texqc
apt-get install -y aspell
apt-get install -y xmlstarlet

tlmgr --verify-repo=none update --self
packages="href-ul huawei ffcode latexmk fmtcount trimspaces \
  libertine paralist makecell footmisc currfile enumitem wrapfig \
  lastpage biblatex titling svg catchfile transparent textpos fvextra \
  xstring framed environ iexec anyfontsize changepage titlesec upquote hyperxmp biber"
tlmgr --verify-repo=none install ${packages}
tlmgr --verify-repo=none update ${packages}

apt-get install -y python3-pygments
python3 -m pip install -r "${HOME}/requirements.txt"

gem install octokit -v 4.21.0
gem install slop -v 4.9.1

add-apt-repository -y ppa:inkscape.dev/stable && \
  apt-get update -y && \
  apt-get install -y inkscape

cd /usr/local && \
  wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F6.55.0/pmd-bin-6.55.0.zip && \
  unzip pmd-bin-6.55.0.zip && \
  rm pmd-bin-6.55.0.zip && \
  mv pmd-bin-6.55.0 pmd && \
  ln -s /usr/local/pmd/bin/run.sh /usr/local/bin/pmd

#install Gradle
wget -q https://services.gradle.org/distributions/gradle-7.4-bin.zip \
    && unzip gradle-7.4-bin.zip -d /opt \
    && rm gradle-7.4-bin.zip
# Set Gradle in the environment variables
export GRADLE_HOME=/opt/gradle-7.4
export PATH=$PATH:/opt/gradle-7.4/bin

wget https://repo1.maven.org/maven2/org/jpeek/jpeek/0.32.0/jpeek-0.32.0-jar-with-dependencies.jar \
    && mkdir -p "$(dirname "${JPEEK}")" \
    && mv jpeek-0.32.0-jar-with-dependencies.jar "${JPEEK}"
