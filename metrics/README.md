# Metrics

## How Metrics Work

Every executable file in this directory is a calculator of a few
metrics. They all are expected to be executed like this:

```bash
./cloc.sh Foo.java log.txt
```

Here, `Foo.java` is the path of the Java file to examine and
`log.txt` is the path of the file where the output is supposed
to be saved.

It is expected, that the `log.txt` will contain the following
text after the script finished successfully:

```text
NoBL 42 Number of Blank Lines
NoCL 44 Number of Commenting Lines
LoC 323 Total physical lines of source code
```

There are three columns in the file. The first one should contain
the name of the metric. The second one contains the value (float or integer).
The third one contains the description of the metric (in general, NOT
for this particular file). A space is mandatory between the first and the
second column, and between the second and the third columns.

## Metrics in make

Metrics could be calculated in **measure** step presented in makefile.
Firstly, executed `steps/measure.sh` that performs preparation steps:

* Creating necessary files and directories
* Collecting jobs to execute in parallel
  (Currently, one for each java file to analyze metrics for)
* Executes jobs using `help/parallel.sh`

For each job it executes `steps/measure-file.sh`
that creates the following file structure:

```text
dataset/
  measurements/
    yegor256/
      cactoos/
        Main.java.m
        Main.java.m.LOC
        Main.java.m.CC
        Main.java.m.CoCo
        ...
```

Where `{file_name}.java.m` is used as a buffer to store intermediate results
during calculations and `{file_name}.java.m.{metric_name}`
stores calculated metric, which has `{metric_name}` name,
for the file with `{file_name}` name
