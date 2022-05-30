
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mlr3fda

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![RCMD
Check](https://github.com/mlr-org/mlr3fda/actions/workflows/rcmdcheck.yaml/badge.svg)](https://github.com/mlr-org/mlr3fda/actions/workflows/rcmdcheck.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/mlr3fda)](https://CRAN.R-project.org/package=mlr3fda)
<!-- badges: end -->

`mlr3` extension for functional data analysis.

## What is `mlr3fda`

`mlr3fda` extends `mlr3` to [functional
data](https://en.wikipedia.org/wiki/Functional_data_analysis). We use
the `tfd_irreg` datatype that is defined in the
\[tf\]\[<https://github.com/fabian-s/tf>\] R package

## Installation

``` r
remotes::install_github("mlr-org/mlr3fda")
```

## Example Usage

Build a `GraphLearner` that first extracts a `numeric()` feature
(`"mean"`) from the functional data and then fits a standard random
forest.

``` r
library("mlr3fda")
library("mlr3verse")
#> Loading required package: mlr3

task = tsk("fuel")
print(task)
#> <TaskRegr:fuel> (129 x 4)
#> * Target: heatan
#> * Properties: -
#> * Features (3):
#>   - fun (2): NIR, UVVIS
#>   - dbl (1): h20
ids = partition(task)

graph = po("ffs", feature = "mean", window = 5, drop = TRUE) %>>%
  po("learner", learner = lrn("regr.ranger"))

glrn = as_learner(graph)

glrn$train(task, row_ids = ids$train)

glrn$predict(task, row_ids = ids$test)
#> <PredictionRegr> for 43 observations:
#>     row_ids   truth response
#>           3 23.8400 22.21507
#>          15 31.1860 28.92541
#>          16 29.9330 26.06360
#> ---                         
#>          25  6.1689 12.32691
#>          47 11.5560 16.28625
#>         117  7.6153 19.13527
```
