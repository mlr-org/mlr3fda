
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

## Installation

``` r
remotes::install_github("mlr-org/mlr3fda")
```

## Example Usage

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
```

``` r
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
#>           3 23.8400 25.43000
#>          10 24.9480 23.42850
#>          12 26.8770 24.69694
#> ---                         
#>          14  7.0037 25.93584
#>          36 12.1890 25.22261
#>         127  8.8315 27.97107
```
