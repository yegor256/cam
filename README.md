[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/ctors-vs-size/blob/master/LICENSE.txt)

Just run this and the entire dataset will be built
(you need to have [Docker](https://docs.docker.com/get-docker/) installed):

```bash
$ docker run --rm -v "$(pwd):/w" yegor256/cam
```

The dataset will be created in the `./dataset` directory.

You can also run it without Docker:

```bash
$ make -C scripts
```

Should work.