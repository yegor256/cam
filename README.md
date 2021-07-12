[![make](https://github.com/yegor256/cam/actions/workflows/make.yml/badge.svg?branch=master)](https://github.com/yegor256/cam/actions/workflows/make.yml)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/ctors-vs-size/blob/master/LICENSE.txt)
[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/yegor256/cam)](https://hub.docker.com/r/yegor256/cam)

This is a dataset of open source Java classes and some metrics on them.
Every now and then I make a new version of it using the scripts
in this repository. You are welcome to use it in your researches.
Each release has a fixed version. By referring to it in your research
you avoid ambiguity and guarantees repeatability of your experiments.

The latest ZIP archive with the dataset is here: 
[cam-2021-07-08.zip](https://github.com/yegor256/cam/releases/download/0.1.1/cam-2021-07-08.zip) (387Mb).
It is the result of the analysis of 1000 Java classes against
eight metrics: 
lines of code,
lines of comments,
blank lines,
NCSS,
cyclomatic complexity,
number of attributes,
number of static attributes,
number of constructors,
number of methods,
number of static methods.

If you want to create a new dataset, 
just run this and the entire dataset will be built
(you need to have [Docker](https://docs.docker.com/get-docker/) installed),
where `1000` is the number of repositories to fetch from GitHub:

```bash
$ docker run --rm -v "$(pwd):/w" -e "TOTAL=1000" -e "TARGET=/w/dataset" yegor256/cam
```

The dataset will be created in the `./dataset` directory (may take some time,
maybe a few days!), and a `.zip` archive will also be there.

You can also run it without Docker:

```bash
$ make TOTAL=100
```

Should work, if you have all dependencies installed, as suggested in the
[Dockerfile](https://github.com/yegor256/cam/blob/master/Dockerfile).
