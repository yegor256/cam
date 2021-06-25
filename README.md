[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/ctors-vs-size/blob/master/LICENSE.txt)
[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/yegor256/cam)](https://hub.docker.com/r/yegor256/cam)

Just run this and the entire dataset will be built
(you need to have [Docker](https://docs.docker.com/get-docker/) installed),
where `100` is the number of repositories to fetch from GitHub:

```bash
$ docker run --rm -v "$(pwd):/w" -e "TOTAL=100" -e "TARGET=/w" yegor256/cam
```

The dataset will be created in the `./dataset` directory (may take some time,
maybe a few hours!), and a `.zip` archive in the current directory.

You can also run it without Docker:

```bash
$ make TOTAL=100
```

Should work.