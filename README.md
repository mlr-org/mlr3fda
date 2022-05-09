
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
data](https://en.wikipedia.org/wiki/Functional_data_analysis). It
introduces the feature type `"functional"`, as well as basic
infrastructure for common operations, such as flattening of functional
data using e.g. `PipeOpFlatFunct`, or feature extraction from functional
data via `PipeOpFFE` (Functional Feature Extraction).

## Installation

``` r
remotes::install_github("mlr-org/mlr3fda")
```

## Example Usage

Build a `GraphLearner` that first extracts features from the functional
data and then fits a standard random forest.

``` r
library(mlr3fda)
library(mlr3verse)
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

# define the features we want to extract
extractors = list(
  mean = extractor_mean(na.rm = TRUE),
  max = extractor_max(na.rm = TRUE),
  slope = extractor_slope()
)
graph = po("ffe", extractors = extractors) %>>%
  po("learner", learner = lrn("regr.ranger"))

glrn = as_learner(graph)

glrn$train(task, row_ids = ids$train)

glrn$predict(task, row_ids = ids$test)
#> <PredictionRegr> for 43 observations:
#>     row_ids   truth response
#>           3 23.8400 23.85014
#>          18 26.1760 22.93755
#>          19 30.6730 23.10221
#> ---                         
#>          14  7.0037 26.67273
#>          25  6.1689 21.72150
#>          36 12.1890 24.24161
```
