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

## Metrics Calculation

Metrics calculation can be elegantly managed during the measure step outlined
in the `Makefile`. This process initiates with the execution of `steps/measure.sh`,
which performs several preparatory tasks:

1. Creating the necessary files and directories.
2. Collecting jobs to execute in parallel,
   with one job designated for each Java file to analyze metrics.
3. Running the jobs using `help/parallel.sh`.

For each job, `steps/measure-file.sh` is executed,
resulting in the following organized file structure:

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

In this structure, `{file_name}.m` serves as a buffer
for intermediate results during calculations.
The files named `{file_name}.m.{metric_name}` store the calculated metrics,
where `{metric_name}` corresponds to the specific metric
for the file `{file_name}`.

## Cognitive Complexity from Java source

`cc.py` writes `CoCoJ`, independently of PMD's `CoCo`, `ACoCo`, `CoCoMx`
and `CoCoMn`. Its description identifies javalang as the implementation.
The value sums method and constructor scores across the compilation unit.
Each executable starts at nesting zero. Member classes are scored independently.
Local and anonymous class bodies increase nesting in their enclosing executable;
their methods and constructors also receive independent scores, as in PMD's
executable rule. Lambdas increase nesting but do not themselves add a point.
Try/resources/finally are transparent; each catch adds one plus nesting.
Switch adds one plus nesting, regardless of its number of cases.
Only labeled break/continue add a jump point.

Recursion adds one point per method in a direct or indirect call cycle,
regardless of the number of recursive call sites. Calls through parameters or
fields of the same source class can resolve to that method. Lambdas belong to
the enclosing method; anonymous methods have their own call-graph nodes.
Qualified `this` selects its named enclosing class; later selectors in a chain
are not treated as calls on `this`. Variable lookup follows the call's lexical
position, including block and switch boundaries, declaration order and captured
variables, inner fields, loop/catch/resource bindings and lambda parameters. An
inferred lambda parameter still shadows a field even when its type is unknown.
This source-only implementation resolves unambiguous calls and simple
same-arity overloads using source argument types. Unknown receiver types and
unresolved same-arity overloads do not create call-graph edges. It does not
perform classpath resolution, inheritance lookup or full Java overload
inference. Keep PMD's metric when those capabilities are required.

The 119 snippets in `tests/metrics/cc-cases.json` record actual PMD 7.5.0
results (the version installed by CAM). `test-cc.sh` runs the installed PMD
against all snippets in one invocation, checks its XML results against the
recorded `pmd` values (also verified with PMD 7.22.0), then checks CoCoJ
against the independent `expected` values. It also checks that appending CoCoJ
preserves an existing CoCo row. Run it with:

```bash
make test TEST=metrics/test-cc.sh
```

Eleven expectations deliberately differ from PMD 7.5.0 (also reproduced with
7.22.0). Control-flow and cycle differences follow the
[Cognitive Complexity specification][cognitive-spec] rather than traversal
behavior in [PMD's visitor][pmd-visitor]. The unresolved-overload case records
the source inference limit:

| Case | PMD | CoCoJ | Reason |
| --- | ---: | ---: | --- |
| `and_or_and` | 2 | 3 | Three logical-operator sequences |
| `or_and_or` | 2 | 3 | Three logical-operator sequences |
| `nested_else_chain_body` | 6 | 5 | No extra chain nesting |
| `recursive_twice` | 2 | 1 | One point per cycle member |
| `mutual_recursion` | 0 | 2 | Two methods in an indirect cycle |
| `recursive_anonymous` | 2 | 0 | A call alone forms no cycle |
| `three_method_cycle` | 0 | 3 | Three methods in an indirect cycle |
| `repeated_indirect_cycle` | 0 | 2 | Repeated edges count once |
| `qualified_outer_this` | 2 | 0 | Inner calls outer with no return edge |
| `qualified_nested_outer_this` | 2 | 0 | Outer receiver has no cycle |
| `unknown_overload_argument` | 1 | 0 | Unresolved argument type |

Negated boolean groups start an independent sequence; parentheses alone do not.
The baseline values stay separate so a PMD change cannot silently redefine
the source metric's expectations.

[cognitive-spec]: https://www.sonarsource.com/docs/CognitiveComplexity.pdf
[pmd-visitor]: https://github.com/pmd/pmd/blob/pmd_releases/7.5.0/pmd-java/src/main/java/net/sourceforge/pmd/lang/java/metrics/internal/CognitiveComplexityVisitor.java
