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

SHELL ["/bin/bash", "--login", "-c"]

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

# Ruby + Java
RUN apt-get update -y --fix-missing \
  && apt-get -y install --no-install-recommends \
    ruby-full=1:3.0~exp1 \
    openjdk-17-jdk=17.0.10+7-1~22.04.1 \
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

# LaTeX
RUN wget --quiet http://mirror.ctan.org/systems/texlive/tlnet/install-tl.zip \
  && unzip install-tl.zip -d install-tl \
  && name=$(find install-tl/ -type d -name 'install-tl-*' -exec basename {} \;) \
  && year=${name:11:4} \
  && export year \
  && perl "./install-tl/${name}/install-tl" --scheme=scheme-medium --no-interaction \
  && arc=$(find "/usr/local/texlive/${year}/bin" -type d -name '*-linux' -exec basename {} \;) \
  && export arc \
  && PATH=${PATH}:/usr/local/texlive/${year}/bin/${arc} \
  && echo "export PATH=\${PATH}:/usr/local/texlive/${year}/bin/${arc}" >> /root/.profile \
  && tlmgr init-usertree \
  && tlmgr install latexmk
ENV PATH "$PATH:/usr/local/texlive/$year/bin/$arc"

WORKDIR /cam
COPY Makefile /cam
COPY requirements.txt /cam
COPY DEPENDS.txt /cam
COPY steps/install.sh /cam/steps/
COPY help/* /cam/help/

RUN make install

COPY . /cam
