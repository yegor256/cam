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
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Ruby + Java
RUN apt-get -y install --no-install-recommends \
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

WORKDIR /cam
COPY Makefile /cam
COPY requirements.txt /cam
COPY DEPENDS.txt /cam
COPY steps/install.sh /cam/steps/
COPY help/* /cam/help/

RUN make install

COPY . /cam
