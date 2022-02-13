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

FROM yegor256/rultor-image:1.6.0

RUN apt -y update && apt install -y cloc shellcheck

RUN gem install texsc
RUN gem install texqc
RUN apt install -y aspell

RUN tlmgr --verify-repo=none update --self
RUN tlmgr --verify-repo=none install href-ul huawei ffcode latexmk fmtcount trimspaces libertine paralist makecell footmisc currfile enumitem wrapfig lastpage biblatex titling svg catchfile transparent textpos fvextra xstring framed environ iexec anyfontsize changepage titlesec
RUN tlmgr --verify-repo=none install biber

RUN apt install -y python3-pygments
RUN mkdir /opt/app
COPY requirements.txt /opt/app
RUN python3 -m pip install -r /opt/app/requirements.txt

RUN gem install --no-user-install octokit -v 4.21.0
RUN gem install --no-user-install slop -v 4.9.1

RUN add-apt-repository ppa:inkscape.dev/stable && \
  apt update -y && \
  apt install -y inkscape

RUN cd /usr/local && \
  wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F6.37.0/pmd-bin-6.37.0.zip && \
  unzip pmd-bin-6.37.0.zip && \
  rm pmd-bin-6.37.0.zip && \
  mv pmd-bin-6.37.0 pmd && \
  ln -s /usr/local/pmd/bin/run.sh /usr/local/bin/pmd

RUN mkdir /usr/local/cam
COPY Makefile /usr/local/cam
COPY discover-repos.rb /usr/local/cam
COPY metrics /usr/local/cam/metrics
COPY filters /usr/local/cam/filters
COPY tex /usr/local/cam/tex

ENTRYPOINT ["make", "-e", "-C", "/usr/local/cam"]
