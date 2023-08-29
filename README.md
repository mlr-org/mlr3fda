
# mlr3fda

Package Website: [dev](https://mlr3fda.mlr-org.com/)

Extending mlr3 to functional data.

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![RCMD
Check](https://github.com/mlr-org/mlr3fda/actions/workflows/rcmdcheck.yaml/badge.svg)](https://github.com/mlr-org/mlr3fda/actions/workflows/rcmdcheck.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/mlr3fda)](https://CRAN.R-project.org/package=mlr3fda)
[![StackOverflow](https://img.shields.io/badge/stackoverflow-mlr3-orange.svg)](https://stackoverflow.com/questions/tagged/mlr3)
[![Mattermost](https://img.shields.io/badge/chat-mattermost-orange.svg)](https://lmmisld-lmu-stats-slds.srv.mwn.de/mlr_invite/)
<!-- badges: end -->

## Installation

This package is not yet on CRAN, you can install the development version
of `mlr3fda` from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mlr-org/mlr3fda")
```

## Status

`mlr3fda` is still in an early stage of development. Nonetheless, all
exported functions are tested and should work.

## What is mlr3fda?

The goal of mlr3fda is to extend `mlr3` to [functional
data](https://en.wikipedia.org/wiki/Functional_data_analysis). We use
the `tfd_reg` and `tfd_irreg` datatypes that are defined in the
[tf](https://github.com/tidyfun/tf) R package.

After loading `mlr3fda` two new feature types are available.

``` r
library(mlr3)
mlr_reflections$task_feature_types
```

    ##         lgl         int         dbl         chr         fct         ord 
    ##   "logical"   "integer"   "numeric" "character"    "factor"   "ordered" 
    ##         pxc 
    ##   "POSIXct"

``` r
library(mlr3fda)
mlr_reflections$task_feature_types
```

    ##         lgl         int         dbl         chr         fct         ord 
    ##   "logical"   "integer"   "numeric" "character"    "factor"   "ordered" 
    ##         pxc         tfr         tfi 
    ##   "POSIXct"   "tfd_reg" "tfd_irreg"

The newly available data types are:

- `tfd_irreg` - irregular functional data, i.e. the function of each
  observation is observed for potentially different values.
- `tfd_reg` - regular functional data, i.e. the function of each
  observation is observed for the same values.

For tutorials on how to create functional data, see the
[documentation](https://github.com/tidyfun/tf) of the tf package.

Here we will start with the predefined fuel task, that has two regular
functional columns as features.

``` r
task = tsk("fuel")
task
```

    ## <TaskRegr:fuel> (129 x 4): Spectral Data of Fossil Fuels
    ## * Target: heatan
    ## * Properties: -
    ## * Features (3):
    ##   - tfr (2): NIR, UVVIS
    ##   - dbl (1): h20

Currently there are no `Learner`s that directly operate on functional
data. However, it is possible to extract simple functional features
using the `PipeOpFFS`, which in the example below calculates the average
functional responses.

``` r
library(mlr3pipelines)

po_fmean = po("ffs", features = "mean")

task_fmean = po_fmean$train(list(task))[[1L]]
task_fmean$head()
```

    ##    heatan    h20                                     NIR
    ## 1: 26.781 2.3000 [1]: (1,  0.2);(2,  0.3);(3,  0.3); ...
    ## 2: 27.472 3.0000 [2]: (1,  0.2);(2,  0.3);(3,  0.2); ...
    ## 3: 23.840 2.0002 [3]: (1,-0.05);(2, 0.05);(3,-0.08); ...
    ## 4: 18.168 1.8500 [4]: (1,-0.08);(2,-0.08);(3, 0.06); ...
    ## 5: 17.517 2.3898 [5]: (1,-0.23);(2,-0.12);(3,-0.04); ...
    ## 6: 20.249 2.4288 [6]: (1,-0.06);(2, 0.09);(3,-0.06); ...
    ##                                      UVVIS   NIR_mean UVVIS_mean
    ## 1: [1]: (1,  0.9);(2,  0.7);(3,  0.8); ... 0.49851677  0.9636931
    ## 2: [2]: (1, -0.9);(2, -1.3);(3, -0.8); ... 0.42557851 -0.7991967
    ## 3: [3]: (1,-0.08);(2,-0.29);(3,-0.20); ... 0.01329275 -0.2645535
    ## 4: [4]: (1, -0.6);(2, -0.5);(3, -0.3); ... 0.02031529 -0.4601558
    ## 5: [5]: (1, -0.6);(2, -1.1);(3, -0.7); ... 0.08319121 -0.7310959
    ## 6: [6]: (1, -0.5);(2, -0.9);(3, -0.7); ... 0.11900065 -0.7882897

This can be combined with a `Learner` into a complete `Graph`. We have
to set `drop = TRUE` so that the original functional features are
removed from the task.

``` r
ids = partition(task)

# drop = TRUE means we remove the functional columns as features
graph = po("ffs", features = "mean", drop = TRUE) %>>%
  po("learner", learner = lrn("regr.rpart"))

glrn = as_learner(graph)

glrn$train(task, row_ids = ids$train)

glrn$predict(task, row_ids = ids$test)
```

    ## <PredictionRegr> for 43 observations:
    ##     row_ids   truth response
    ##           3 23.8400 13.73490
    ##           9 26.6610 22.63414
    ##          10 24.9480 28.51553
    ## ---                         
    ##          14  7.0037 25.63514
    ##         126 11.8050 13.73490
    ##         127  8.8315 25.63514

## Bugs, Questions, Feedback

*mlr3fda* is a free and open source software project that encourages
participation and feedback. If you have any issues, questions,
suggestions or feedback, please do not hesitate to open an “issue” about
it on the GitHub page!

In case of problems / bugs, it is often helpful if you provide a
“minimum working example” that showcases the behaviour (but don’t worry
about this if the bug is obvious).

Please understand that the resources of the project are limited:
response may sometimes be delayed by a few days, and some feature
suggestions may be rejected if they are deemed too tangential to the
vision behind the project.
