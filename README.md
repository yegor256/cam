[![make](https://github.com/yegor256/cam/actions/workflows/make.yml/badge.svg?branch=master)](https://github.com/yegor256/cam/actions/workflows/make.yml)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/ctors-vs-size/blob/master/LICENSE.txt)
[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/yegor256/cam)](https://hub.docker.com/r/yegor256/cam)

This is a dataset of open source Java classes and some metrics on them.
Every now and then I make a new version of it using the scripts
in this repository. You are welcome to use it in your researches.
Each release has a fixed version. By referring to it in your research
you avoid ambiguity and guarantees repeatability of your experiments.

The latest ZIP archive with the dataset is here:
[cam-2022-02-17.zip](https://github.com/yegor256/cam/releases/download/0.3.0/cam-2022-02-17.zip) 
(532Mb). 
It is the result of the analysis of Java classes in 1000 GitHub repositories
against a number of metrics:
 
  * lines of code (reported by [cloc](https://github.com/AlDanial/cloc)),
  * lines of comments,
  * blank lines,
  * [NCSS](https://stackoverflow.com/questions/5486983/what-does-ncss-stand-for),
  * cyclomatic complexity,
  * number of attributes,
  * number of static attributes,
  * number of constructors,
  * number of methods,
  * number of static methods,
  * total cognitive complexity (reported by [PMD](https://pmd.github.io/)),
  * maximum cognitive complexity,
  * minimum cognitive complexity,
  * average cognitive complexity,
  * number of committers.

Previous archives (took me a few days to build each of them, using a pretty big machine):

* [cam-2021-08-04.zip](https://github.com/yegor256/cam/releases/download/0.2.0/cam-2021-08-04.zip) 
  (692Mb): 1000 repos, 15 metrics
* [cam-2021-07-08.zip](https://github.com/yegor256/cam/releases/download/0.1.1/cam-2021-07-08.zip) 
  (387Mb): 1000 repos, 11 metrics

If you want to create a new dataset,
just run the following command and the entire dataset will be built in the current directory
(you need to have [Docker](https://docs.docker.com/get-docker/) installed),
where `1000` is the number of repositories to fetch from GitHub
and `XXX` is
your [personal access token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token):

```bash
$ docker run --detach --name=cam --rm --volume "$(pwd):/dataset" \
  -e "TOKEN=XXX" -e "TOTAL=1000" -e "TARGET=/dataset" \
  yegor256/cam:0.6.1 "make -e >/dataset/make.log 2>&1"
```

This command will create a new Docker container, running in the background.
(run `docker ps -a`, in order to see it).
If you want to run docker interactively and see all the logs, you can just
disable [detached mode](https://docs.docker.com/language/golang/run-containers/#run-in-detached-mode)
by removing the `--detach` option from the command.

The dataset will be created in the current directory (may take some time,
maybe a few days!), and a `.zip` archive will also be there. Docker container
will run in the background: you can safely close the console and come back when the
dataset is ready and the container is deleted.

You can also run it without Docker:

```bash
$ make wipe
$ make TOTAL=100
```

Should work, if you have all the dependencies installed, as suggested in the
[Dockerfile](https://github.com/yegor256/cam/blob/master/Dockerfile).

In order to analyze just a single repository, do this:

```bash
$ make wipe
$ make REPO=yegor256/jpeek
```

## How to Calculate Additional Metrics

You may want to use this dataset as a basis, with an intend of adding your own
metrics on top of it. It should be easy:

  * Download ZIP archive
  * Unpack it to a new `cam/` directory
  * Add a new script to the `cam/metrics/` directory (use `ast_metrics.py` as an example)
  * Run `make` in the `cam/` directory

Make should understand that a new metric was added. It will apply this new metric
to all `.java` files, generate new `.csv` reports, and then the final `.pdf` report
will also be updated.

## How to Contribute

Fork repository, make changes, send us a [pull request](https://www.yegor256.com/2014/04/15/github-guidelines.html).
We will review your changes and apply them to the `master` branch shortly,
provided they don't violate our quality standards. To avoid frustration,
before sending us your pull request please run full Maven build:

```bash
$ make REPO=yegor256/tojos
```

This should take a few minutes to complete.
