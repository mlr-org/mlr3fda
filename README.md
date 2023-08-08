
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
    ##         pxc       f_reg     f_irreg 
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
    ##   - f_reg (2): NIR, UVVIS
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

    ##    heatan    h20
    ## 1: 26.781 2.3000
    ## 2: 27.472 3.0000
    ## 3: 23.840 2.0002
    ## 4: 18.168 1.8500
    ## 5: 17.517 2.3898
    ## 6: 20.249 2.4288
    ##                                                                                        NIR
    ## 1:                         0.2340554,0.2904143,0.2985390,0.2857719,0.4317163,0.4128493,...
    ## 2:                         0.2438254,0.3175793,0.1569265,0.3040594,0.2788988,0.2041318,...
    ## 3:             -0.05197412, 0.04500882,-0.07834500, 0.12620942,-0.09833023, 0.02935566,...
    ## 4:       -0.081765370,-0.082304927, 0.058605750,-0.024858584,-0.006321834,-0.060674486,...
    ## 5:             -0.22812462,-0.11606918,-0.04202395,-0.11545658,-0.08707948,-0.07724899,...
    ## 6: -0.0552376200, 0.0895360730,-0.0584367503,-0.1728105836,-0.0343947343,-0.0002479363,...
    ##                                                                          UVVIS
    ## 1:             0.8743160,0.7481823,0.7738064,0.7471426,0.5223545,0.8142814,...
    ## 2:       -0.8551739,-1.2873925,-0.8328261,-0.9758280,-0.7976276,-0.9203199,...
    ## 3: -0.08469889,-0.29369554,-0.20151308,-0.26229300,-0.27280263,-0.31936488,...
    ## 4:       -0.5821539,-0.4851725,-0.3282551,-0.5389530,-0.4092186,-0.3816549,...
    ## 5:       -0.6435039,-1.1232725,-0.6649561,-0.7912230,-0.7875426,-0.7048599,...
    ## 6:       -0.5037039,-0.8896675,-0.6620511,-0.7437430,-0.7579426,-0.8136399,...
    ##      NIR_mean UVVIS_mean
    ## 1: 0.49851677  0.9636931
    ## 2: 0.42557851 -0.7991967
    ## 3: 0.01329275 -0.2645535
    ## 4: 0.02031529 -0.4601558
    ## 5: 0.08319121 -0.7310959
    ## 6: 0.11900065 -0.7882897

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
