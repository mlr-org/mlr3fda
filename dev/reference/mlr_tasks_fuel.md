# Fuel Regression Task

This dataset contains two functional covariates and one scalar
covariate. The goal is to predict the heat value of some fuel based on
the ultraviolet radiation spectrum and infrared ray radiation and one
scalar column called h2o.

This is a subset of the full dataset, which is contained in the package
`FDboost`.

## Format

[R6::R6Class](https://r6.r-lib.org/reference/R6Class.html) inheriting
from [mlr3::TaskRegr](https://mlr3.mlr-org.com/reference/TaskRegr.html).

## Dictionary

This [Task](https://mlr3.mlr-org.com/reference/Task.html) can be
instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_tasks](https://mlr3.mlr-org.com/reference/mlr_tasks.html) or with
the associated sugar function
[tsk()](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_tasks$get("fuel")
    tsk("fuel")

## Meta Information

- Task type: “regr”

- Dimensions: 129x4

- Properties: -

- Has Missings: `FALSE`

- Target: “heatan”

- Features: “NIR”, “UVVIS”, “h2o”

## References

Brockhaus, Sarah, Scheipl, Fabian, Hothorn, Torsten, Greven, Sonja
(2015). “The functional linear array model.” *Statistical Modelling*,
**15**(3), 279–300.

## See also

- Chapter in the [mlr3book](https://mlr3book.mlr-org.com/):
  <https://mlr3book.mlr-org.com/chapters/chapter2/data_and_basic_modeling.html>

- Package [mlr3data](https://CRAN.R-project.org/package=mlr3data) for
  more toy tasks.

- Package [mlr3oml](https://CRAN.R-project.org/package=mlr3oml) for
  downloading tasks from <https://www.openml.org>.

- Package [mlr3viz](https://CRAN.R-project.org/package=mlr3viz) for some
  generic visualizations.

- [Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  of [Tasks](https://mlr3.mlr-org.com/reference/Task.html):
  [mlr_tasks](https://mlr3.mlr-org.com/reference/mlr_tasks.html)

- `as.data.table(mlr_tasks)` for a table of available
  [Tasks](https://mlr3.mlr-org.com/reference/Task.html) in the running
  session (depending on the loaded packages).

- [mlr3fselect](https://CRAN.R-project.org/package=mlr3fselect) and
  [mlr3filters](https://CRAN.R-project.org/package=mlr3filters) for
  feature selection and feature filtering.

- Extension packages for additional task types:

  - Unsupervised clustering:
    [mlr3cluster](https://CRAN.R-project.org/package=mlr3cluster)

  - Probabilistic supervised regression and survival analysis:
    <https://mlr3proba.mlr-org.com/>.

Other Task:
[`mlr_tasks_dti`](https://mlr3fda.mlr-org.com/dev/reference/mlr_tasks_dti.md),
[`mlr_tasks_phoneme`](https://mlr3fda.mlr-org.com/dev/reference/mlr_tasks_phoneme.md)
