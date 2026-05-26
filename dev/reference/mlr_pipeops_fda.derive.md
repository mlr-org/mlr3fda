# Derivatives of Functional Columns

Computes derivatives of functional features via
[`tf::tf_derive()`](https://tidyfun.github.io/tf/reference/tf_derive.html).
For `tfd` inputs derivatives are obtained by finite differencing of the
function evaluations, for `tfb` inputs by finite differencing of the
basis functions.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html),
as well as the following parameters:

- `order` :: `integer(1)`  
  Order of the derivative. Must be a positive integer. Initial value is
  `1`.

- `arg` :: [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  Optional grid to use for the finite differences. If `NULL` (the
  default), the argument grid of each functional column is used. For
  `tfd_irreg` inputs, supplying `arg` interpolates the data to a common
  grid before differentiating.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDADerive`

## Methods

### Public methods

- [`PipeOpFDADerive$new()`](#method-PipeOpFDADerive-initialize)

- [`PipeOpFDADerive$clone()`](#method-PipeOpFDADerive-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFDADerive$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDADerive$new(id = "fda.derive", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fda.derive"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFDADerive$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDADerive$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
po_deriv = po("fda.derive", order = 1)
task_deriv = po_deriv$train(list(task))[[1L]]
task_deriv$data(cols = c("NIR", "UVVIS"))
#>                                                                                               NIR
#>                                                                                         <tfd_reg>
#>   1:        0.080476076, 0.032241810,-0.002321203, 0.066588633, 0.063538674,-0.056916652,...[231]
#>   2:        0.190957326,-0.043449440,-0.006759953, 0.060986133,-0.049963826, 0.003054598,...[231]
#>   3:        0.207151326,-0.013185440, 0.040600297,-0.009992617,-0.048426876, 0.073956348,...[231]
#>   4:             -0.07126467, 0.07018556, 0.02872317,-0.03246379,-0.01790795, 0.01027730,...[231]
#>   5:  0.1310605511, 0.0930503349, 0.0003062967,-0.0225277670, 0.0191037986,-0.0252437770,...[231]
#>  ---                                                                                             
#> 125:              0.03992536,-0.01254063,-0.02074358, 0.03277303, 0.03890707,-0.04242225,...[231]
#> 126:        0.132336076,-0.011433190, 0.005855047, 0.028799883,-0.001586326,-0.019654152,...[231]
#> 127:             -0.13237267,-0.03466444, 0.05113130, 0.01475363,-0.01551633, 0.03351710,...[231]
#> 128:       -0.001568599, 0.026418135, 0.009559584,-0.065045367,-0.024422201, 0.037028598,...[231]
#> 129:       -0.010886799, 0.035524685,-0.010005828,-0.007691367, 0.027197424,-0.003885402,...[231]
#>                                                                                       UVVIS
#>                                                                                   <tfd_reg>
#>   1:       -0.20201260,-0.05025479,-0.00051985,-0.12572598, 0.03356941, 0.15388724,...[134]
#>   2:       -0.87561120, 0.01117391, 0.15578227, 0.01759922, 0.02775406,-0.11878041,...[134]
#>   3:       -0.35958620,-0.05840709, 0.01570127,-0.03564478,-0.02853594,-0.05885541,...[134]
#>   4:        0.06701330, 0.12694941,-0.02689023,-0.04048178, 0.07864906,-0.03973241,...[134]
#>   5:       -0.94881120,-0.01072609, 0.16602477,-0.06129328, 0.04318156,-0.05838041,...[134]
#>  ---                                                                                       
#> 125: -0.239898704,-0.024418592, 0.090484772,-0.089355776, 0.004841559, 0.116339585,...[134]
#> 126:  0.342861296,-0.059538592,-0.007585228, 0.138441724, 0.078534059, 0.029389585,...[134]
#> 127:        0.56913130,-0.05360859,-0.02704273, 0.03298922,-0.05014344, 0.08097209,...[134]
#> 128:        0.06328260, 0.04745711,-0.01851120, 0.01086792, 0.10201979,-0.03862279,...[134]
#> 129:       -1.39931120,-0.12550609, 0.26038727, 0.12986922, 0.01452906,-0.18094041,...[134]
```
