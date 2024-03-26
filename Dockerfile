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

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Build essentials that are required later
RUN apt-get update -y --fix-missing \
  && apt-get -y install --no-install-recommends \
    build-essential=12.9ubuntu3 \
    software-properties-common=0.99.22.9 \
    make=4.3-4.1build1 \
    wget=1.21.2-2ubuntu1 \
    libssl-dev=3.0.2-0ubuntu1.15 \
    openssl=3.0.2-0ubuntu1.15 \
    gpg-agent=2.2.27-3ubuntu2.1 \
    zip=3.0-12build2 \
    unzip=6.0-26ubuntu3.2 \
    tree=2.0.2-1 \
    parallel=20210822+ds-2 \
    bc=1.07.1-3build1 \
    cloc=1.90-1 \
    jq=1.6-2.1ubuntu3 \
    shellcheck=0.8.0-2 \
    aspell=0.60.8-4build1 \
    xmlstarlet=1.6.1-2.1 \
    xpdf=3.04+git20220201-1 \
    coreutils=8.32-4.1ubuntu1.1 \
    gawk=1:5.1.0-1ubuntu0.1 \
    git=1:2.34.1-1ubuntu1.10 \
    libxml2-utils=2.9.13+dfsg-1ubuntu0.4 \
    build-essential=12.9ubuntu3 \
    cmake=3.22.1-1ubuntu1.22.04.2 \
    libfreetype6-dev=2.11.1+dfsg-1ubuntu0.2 \
    pkg-config=0.29.2-1ubuntu3 \
    libfontconfig-dev=2.13.1-4.2ubuntu5 \
    libjpeg-dev=8c-2ubuntu10 \
    libopenjp2-7-dev=2.4.0-6 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Inkscape
RUN apt-get update -y --fix-missing \
  && add-apt-repository -y ppa:inkscape.dev/stable \
  && apt-get update -y \
  && apt-get -y install --no-install-recommends \
    inkscape=1:1.3.2+202311252150+091e20ef0f~ubuntu22.04.1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# LaTeX
RUN wget --quiet http://mirror.ctan.org/systems/texlive/tlnet/install-tl.zip \
  && unzip install-tl.zip -d install-tl \
  && name=$(find install-tl/ -type d -name "install-tl-*" -exec basename {} \;) \
  && year=${name:11:4} \
  && perl "./install-tl/${name}/install-tl" --scheme=scheme-medium --no-interaction \
  && arc=$(find "/usr/local/texlive/${year}/bin" -type d -name "*-linux" -exec basename {} \;) \
  && bin=/usr/local/texlive/${year}/bin/${arc} \
  && export PATH=${PATH}:${bin} \
  && echo "export PATH=\${PATH}:${bin}" > /etc/profile.d/texlive.sh \
  && chmod a+x /etc/profile.d/texlive.sh \
  && tlmgr init-usertree \
  && tlmgr install latexmk \
  && rm -rf install-tl execs.txt

# Ruby
RUN apt-get update -y --fix-missing \
  && apt-get -y install --no-install-recommends \
    ruby-full=1:3.0~exp1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Java + Maven
RUN apt-get update -y --fix-missing \
  && apt-get -y install --no-install-recommends \
    openjdk-17-jdk=17.0.10+7-1~22.04.1 \
    maven=3.6.3-5 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Python
RUN add-apt-repository -y ppa:deadsnakes/ppa \
  && apt-get update -y --fix-missing \
  && apt-get -y install --no-install-recommends \
    python3.7=3.7.17-1+jammy1 \
    python3-pip=22.0.2+dfsg-1ubuntu0.4 \
    python3.7-dev=3.7.17-1+jammy1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /cam
COPY Makefile /cam
COPY requirements.txt /cam
COPY DEPENDS.txt /cam
COPY steps/install.sh /cam/steps/
COPY help/* /cam/help/

ENV LOCAL /cam

COPY installs/install-texlive.sh /cam/installs/install-texlive.sh
RUN installs/install-texlive.sh

COPY installs/install-pmd.sh /cam/installs/install-pmd.sh
RUN installs/install-pmd.sh

COPY installs/install-gradle.sh /cam/installs/install-gradle.sh
RUN installs/install-gradle.sh
ENV GRADLE_LOCAL /usr/local/gradle
ENV PATH $PATH:/usr/local/gradle/bin

COPY installs/install-gem.sh /cam/installs/install-gem.sh
RUN installs/install-gem.sh

COPY installs/install-jpeek.sh /cam/installs/install-jpeek.sh
ENV JPEEK /opt/app/jpeek.jar
RUN installs/install-jpeek.sh

COPY installs/install-pip.sh /cam/installs/install-pip.sh
RUN installs/install-pip.sh

COPY installs/install-poppler.sh /cam/installs/install-poppler.sh
RUN installs/install-poppler.sh

COPY . /cam
