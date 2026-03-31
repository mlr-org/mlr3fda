# Extracts Random Effects from Functional Columns

This is the class that extracts random effects, specifically random
intercepts and random slopes, from functional columns. This PipeOp fits
a linear mixed model, specifically a random intercept and random slope
model, using the
[`lme4::lmer()`](https://rdrr.io/pkg/lme4/man/lmer.html) function. The
target variable is the value of the functional feature which is
regressed on the functional feature's argument while subject id
determines the grouping structure. After model estimation, the random
effects are extracted and assigned to the correct id.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html).

## Naming

The new names append `_random_intercept` and `_random_slope` to the
corresponding column name of the functional feature.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDARandomEffect`

## Methods

### Public methods

- [`PipeOpFDARandomEffect$new()`](#method-PipeOpFDARandomEffect-new)

- [`PipeOpFDARandomEffect$clone()`](#method-PipeOpFDARandomEffect-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

Initializes a new instance of this Class

#### Usage

    PipeOpFDARandomEffect$new(id = "fda.random_effect", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`) Identifier of the operator, default is
  `"fda.random_effect"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html)) List of
  hyperparameter settings, overwriting default settings set during
  construction.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDARandomEffect$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("dti")
po_fre = po("fda.random_effect")
task_fre = po_fre$train(list(task))[[1L]]
```
