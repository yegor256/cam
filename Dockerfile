# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Build essentials that are required later
RUN apt-get update -y --fix-missing \
  && apt-get -y install --no-install-recommends \
    build-essential=12.* \
    software-properties-common=0.* \
    make=4.* \
    wget=1.* \
    libssl-dev=3.* \
    openssl=3.* \
    gpg-agent=2.* \
    zip=3.* \
    unzip=6.* \
    tree=2.* \
    parallel=* \
    bc=1.* \
    cloc=1.* \
    jq=1.* \
    shellcheck=0.* \
    aspell=0.* \
    xmlstarlet=1.* \
    xpdf=3.* \
    coreutils=* \
    gawk=* \
    git=1:2.* \
    libxml2-utils=2.* \
    build-essential=12.* \
    cmake=3.* \
    libfreetype-dev=* \
    pkg-config=* \
    libfontconfig-dev=2.* \
    libjpeg-dev=* \
    libopenjp2-7-dev=2.* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Inkscape
RUN apt-get update -y --fix-missing \
  && add-apt-repository -y ppa:inkscape.dev/stable \
  && apt-get update -y \
  && apt-get -y install --no-install-recommends \
    inkscape=1:1.* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Ruby
RUN apt-get update -y --fix-missing \
  && apt-get -y install --no-install-recommends \
    ruby-full=1:3.* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Java + Maven
RUN apt-get update -y --fix-missing \
  && apt-get -y install --no-install-recommends \
    openjdk-17-jdk=17.* \
    maven=3.* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Python
RUN add-apt-repository -y ppa:deadsnakes/ppa \
  && apt-get update -y --fix-missing \
  && apt-get -y install --no-install-recommends \
    python3=* \
    python3-venv=* \
    python3-pip=* \
    python3-dev=* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /cam
COPY Makefile /cam
COPY steps/install.sh /cam/steps/
COPY help/* /cam/help/

ENV LOCAL=/cam

COPY installs/install-pmd.sh installs/
RUN installs/install-pmd.sh

COPY installs/install-gradle.sh installs/
RUN installs/install-gradle.sh
ENV GRADLE_LOCAL=/usr/local/gradle
ENV PATH=$PATH:/usr/local/gradle/bin

COPY installs/install-gems.sh installs/
RUN installs/install-gems.sh

COPY installs/install-jpeek.sh installs/
ENV JPEEK=/opt/app/jpeek.jar
RUN installs/install-jpeek.sh

COPY installs/install-poppler.sh installs/
RUN installs/install-poppler.sh

COPY requirements.txt /cam
COPY installs/install-pip.sh installs/
RUN installs/install-pip.sh

COPY installs/install-texlive-base.sh installs/
RUN installs/install-texlive-base.sh
COPY DEPENDS.txt /cam
COPY installs/install-texlive-depends.sh installs/
RUN installs/install-texlive-depends.sh

COPY . /cam
