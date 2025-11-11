# Cross-Correlation of Functional Data

Calculates the cross-correlation between two functional vectors using
[`tf::tf_crosscor()`](https://tidyfun.github.io/tf/reference/functionwise.html).
Note that it only operates on regular data and that the
cross-correlation assumes that each column has the same domain.

To apply this `PipeOp` to irregualr data, convert it to a regular grid
first using
[`PipeOpFDAInterpol`](https://mlr3fda.mlr-org.com/dev/reference/mlr_pipeops_fda.interpol.md).
If you need to change the domain of the columns, use
[`PipeOpFDAScaleRange`](https://mlr3fda.mlr-org.com/dev/reference/mlr_pipeops_fda.scalerange.md).

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html),
as well as the following parameters:

- `arg` :: [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  Grid to use for the cross-correlation.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDACor`

## Methods

### Public methods

- [`PipeOpFDACor$new()`](#method-PipeOpFDACor-new)

- [`PipeOpFDACor$clone()`](#method-PipeOpFDACor-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDACor$new(id = "fda.cor", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fda.cor"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDACor$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
set.seed(1234L)
dt = data.table(y = 1:100, x1 = tf::tf_rgp(100L), x2 = tf::tf_rgp(100L))
task = as_task_regr(dt, target = "y")
po_cor = po("fda.cor")
task_cor = po_cor$train(list(task))[[1L]]
task_cor
#> 
#> ── <TaskRegr> (100x2) ──────────────────────────────────────────────────────────
#> • Target: y
#> • Properties: -
#> • Features (1):
#>   • dbl (1): x1_x2_cor
```
