# How It Works

The entire process of gathering metrics from GitHub repos consists of these
steps:

* **Discovering**. Here we fetch the list of repos from GitHub and then create
directories for them.
* **Polishing**. Then we delete directories that don't exist in the list of
required repositories.
* **Unregistering**. During this step, we clean directories from the CSV
register if their clones are absent.
* **Cloning**. In this step we run `git clone` on found repositories.
* **JPEEK**. Here, we build those gathered repositories and run
[jpeek](https://github.com/cqfn/jpeek) on them.
* **Filtering**. Is where we apply
[all the filters](https://github.com/yegor256/cam/tree/master/filters)
in order to get rid of irrelevant classes (such as `*Test`, `*ITCase`, invalid
files and so on). Whole filtering process will be printed in the final report,
you can check it [here](http://cam.yegor256.com/cam-2024-03-02.pdf).
* **Measuring**. We calculate metrics for each file using these
[metrics](https://github.com/yegor256/cam/tree/master/metrics).
* **Aggregating**. We aggregate all metrics in summary CSV files.
* **Summarization**. Generate summary statistics (count, sum, average, etc.)
for each metric and save them in data/summary/{metric}.csv.
