
# mlr3fda

Package Website: [dev](https://mlr3fda.mlr-org.com/)

Extending mlr3 to functional data.

<!-- badges: start -->

[![RCMD
Check](https://github.com/mlr-org/mlr3fda/actions/workflows/rcmdcheck.yaml/badge.svg)](https://github.com/mlr-org/mlr3fda/actions/workflows/rcmdcheck.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/mlr3fda)](https://CRAN.R-project.org/package=mlr3fda)
[![StackOverflow](https://img.shields.io/badge/stackoverflow-mlr3-orange.svg)](https://stackoverflow.com/questions/tagged/mlr3)
[![Mattermost](https://img.shields.io/badge/chat-mattermost-orange.svg)](https://lmmisld-lmu-stats-slds.srv.mwn.de/mlr_invite/)
<!-- badges: end -->

## Installation

You can either install the latest release from CRAN, or the development
version from [GitHub](https://github.com/):

``` r
# install from CRAN
install.packages("mlr3fda")
# install from GitHub
pak::pak("mlr-org/mlr3fda")
```

## What is mlr3fda?

The goal of `mlr3fda` is to extend `mlr3` to [functional
data](https://en.wikipedia.org/wiki/Functional_data_analysis). This is
achieved by adding support for functional feature types and providing
preprocessing `PipeOp`s that operates on functional columns. For
representing functional data, the `tfd_reg` and `tfd_irreg` datatypes
from the [tf](https://github.com/tidyfun/tf) package are used and are
available after loading `mlr3fda`:

``` r
library(mlr3fda)
mlr_reflections$task_feature_types[c("tfr", "tfi")]
#>         tfr         tfi 
#>   "tfd_reg" "tfd_irreg"
```

These datatypes can be used to represent regular and irregular
functional data respectively. Currently, `Learner`s that directly
operate on functional data are not available, so it is necessary to
first extract scalar features from the functional columns.

# Quickstart

Here we will start with the predefined `dti` (Diffusion Tensor Imaging)
task, see `tsk("dti")$help()` for more details. Besides scalar columns,
this task also contains two functional columns `cca` and `rcst`.

``` r
task = tsk("dti")
task
#> <TaskRegr:dti> (340 x 4): Diffusion Tensor Imaging (DTI)
#> * Target: pasat
#> * Properties: groups
#> * Features (3):
#>   - tfi (2): cca, rcst
#>   - fct (1): sex
#> * Groups: subject_id
```

To train a model on this task we first need to extract scalar features
from the functions. We illustrate this below by extracting the mean
value.

``` r
library(mlr3pipelines)

po_fmean = po("fda.extract", features = "mean")

task_fmean = po_fmean$train(list(task))[[1L]]
task_fmean$head()
#>    pasat    sex  cca_mean rcst_mean
#> 1:    31 female 0.4493332 0.4968519
#> 2:    31 female 0.4441292 0.4810724
#> 3:    29 female 0.4257795 0.5102722
#> 4:    34 female 0.4418538 0.5453188
#> 5:    37 female 0.4700994 0.5471177
#> 6:    40 female 0.4873356 0.4969408
```

This can be combined with a `Lerner` into a `GraphLearner` that first
extracts features and then trains a model.

``` r
# split data into train and test set
ids = partition(task, stratify = FALSE)

# define a Graph and convert it to a GraphLearner
graph = po("fda.extract", features = "mean", drop = TRUE) %>>%
  po("learner", learner = lrn("regr.rpart"))

glrn = as_learner(graph)

# train the graph learner on the train set
glrn$train(task, row_ids = ids$train)

# make predictions on the test set
glrn$predict(task, row_ids = ids$test)
#> <PredictionRegr> for 111 observations:
#>     row_ids truth response
#>          11    48 49.99174
#>          12    40 49.99174
#>          13    43 52.42105
#> ---                       
#>         324    57 52.42105
#>         325    57 41.30769
#>         326    60 49.99174
```

## Implemented PipeOps

| Key                                                                            | Label                                            | Packages                                           | Tags                |
|:-------------------------------------------------------------------------------|:-------------------------------------------------|:---------------------------------------------------|:--------------------|
| [fda.extract](https://mlr3fda.mlr-org.com/reference/mlr_pipeops_fda.extract)   | Extracts Simple Features from Functional Columns | [tf](https://cran.r-project.org/package=tf)        | fda, data transform |
| [fda.flatten](https://mlr3fda.mlr-org.com/reference/mlr_pipeops_fda.flatten)   | Flattens Functional Columns                      | [tf](https://cran.r-project.org/package=tf)        | fda, data transform |
| [fda.fpca](https://mlr3fda.mlr-org.com/reference/mlr_pipeops_fda.fpca)         | Functional Principal Component Analysis          | [tf](https://cran.r-project.org/package=tf)        | fda, data transform |
| [fda.interpol](https://mlr3fda.mlr-org.com/reference/mlr_pipeops_fda.interpol) | Interpolate Functional Columns                   | [tf](https://cran.r-project.org/package=tf)        | fda, data transform |
| [fda.smooth](https://mlr3fda.mlr-org.com/reference/mlr_pipeops_fda.smooth)     | Smoothing Functional Columns                     | [tf](https://cran.r-project.org/package=tf), stats | fda, data transform |

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

## Acknowledgements

The development of this R-package was supported by Roche Diagonstics
R&D.
