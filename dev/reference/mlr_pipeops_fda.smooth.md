# Smoothing Functional Columns

Smoothes functional data using
[`tf::tf_smooth()`](https://tidyfun.github.io/tf/reference/tf_smooth.html).
This preprocessing operator is similar to
[`PipeOpFDAInterpol`](https://mlr3fda.mlr-org.com/dev/reference/mlr_pipeops_fda.interpol.md),
however it does not interpolate to unobserved x-values, but rather
smooths the observed values.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html),
as well as the following parameters:

- `method` :: `character(1)`  
  One of:

  - `"lowess"`: locally weighted scatterplot smoothing (default)

  - `"rollmean"`: rolling mean

  - `"rollmedian"`: rolling median

  - `"savgol"`: Savitzky-Golay filtering

  All methods but `"lowess"` ignore non-equidistant arg values.

- `args` :: named [`list()`](https://rdrr.io/r/base/list.html)  
  List of named arguments that is passed to `tf_smooth()`. See the help
  page of `tf_smooth()` for default values.

- `verbose` :: `logical(1)`  
  Whether to print messages during the transformation. Is initialized to
  `FALSE`.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDASmooth`

## Methods

### Public methods

- [`PipeOpFDASmooth$new()`](#method-PipeOpFDASmooth-new)

- [`PipeOpFDASmooth$clone()`](#method-PipeOpFDASmooth-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDASmooth$new(id = "fda.smooth", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fda.smooth"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDASmooth$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
po_smooth = po("fda.smooth", method = "rollmean", args = list(k = 5))
task_smooth = po_smooth$train(list(task))[[1L]]
task_smooth
#> 
#> ── <TaskRegr> (129x4): Spectral Data of Fossil Fuels ───────────────────────────
#> • Target: heatan
#> • Properties: -
#> • Features (3):
#>   • tfr (2): NIR, UVVIS
#>   • dbl (1): h2o
task_smooth$data(cols = c("NIR", "UVVIS"))
#>                                                                                         NIR
#>                                                                                   <tfd_reg>
#>   1:                   0.3080994,0.3080994,0.3080994,0.3438582,0.3493519,0.3642244,...[231]
#>   2:                   0.2602579,0.2602579,0.2602579,0.2523192,0.2458049,0.2428769,...[231]
#>   3: -0.011486223,-0.011486223,-0.011486223, 0.004779734, 0.005694461, 0.041414870,...[231]
#>   4: -0.027328993,-0.027328993,-0.027328993,-0.023110816,-0.003803279,-0.006494270,...[231]
#>   5:       -0.11775076,-0.11775076,-0.11775076,-0.08757564,-0.09187521,-0.10214986,...[231]
#>  ---                                                                                       
#> 125:       -0.03642132,-0.03642132,-0.03642132,-0.02641745,-0.03803186,-0.01947684,...[231]
#> 126:             -0.6009361,-0.6009361,-0.6009361,-0.5871383,-0.6001436,-0.5713456,...[231]
#> 127:             -0.7666446,-0.7666446,-0.7666446,-0.7691023,-0.7469561,-0.7259121,...[231]
#> 128:       -0.05420742,-0.05420742,-0.05420742,-0.05766751,-0.06079192,-0.06414738,...[231]
#> 129:                   0.1306031,0.1306031,0.1306031,0.1399435,0.1470589,0.1411494,...[231]
#>                                                                           UVVIS
#>                                                                       <tfd_reg>
#>   1:       0.7331604,0.7331604,0.7331604,0.7211534,0.7375428,0.7324643,...[134]
#>   2: -0.9497696,-0.9497696,-0.9497696,-0.9627988,-0.9123580,-0.9273289,...[134]
#>   3: -0.2230006,-0.2230006,-0.2230006,-0.2699338,-0.2892974,-0.3231479,...[134]
#>   4: -0.4687506,-0.4687506,-0.4687506,-0.4286508,-0.4293530,-0.4657681,...[134]
#>   5: -0.8020996,-0.8020996,-0.8020996,-0.8143708,-0.7705770,-0.7629269,...[134]
#>  ---                                                                           
#> 125: -0.6129706,-0.6129706,-0.6129706,-0.6012718,-0.5738140,-0.5840049,...[134]
#> 126: -0.8996776,-0.8996776,-0.8996776,-0.8429658,-0.8279810,-0.7604909,...[134]
#> 127: -0.8241326,-0.8241326,-0.8241326,-0.8034548,-0.8308660,-0.8114889,...[134]
#> 128:       0.5729894,0.5729894,0.5729894,0.6174668,0.6142737,0.5985495,...[134]
#> 129: -0.7885246,-0.7885246,-0.7885246,-0.8310398,-0.7491890,-0.7497129,...[134]
```
