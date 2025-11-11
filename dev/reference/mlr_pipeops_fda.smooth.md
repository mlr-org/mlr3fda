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

  - `"rollmedian"`: rolling meadian

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
#>   • dbl (1): h20
task_smooth$data(cols = c("NIR", "UVVIS"))
#>                                           NIR
#>                                     <tfd_reg>
#>   1:  [1]: (1,  0.3);(2,  0.3);(3,  0.3); ...
#>   2:  [2]: (1,  0.3);(2,  0.3);(3,  0.3); ...
#>   3:  [3]: (1,-0.01);(2,-0.01);(3,-0.01); ...
#>   4:  [4]: (1,-0.03);(2,-0.03);(3,-0.03); ...
#>   5:  [5]: (1, -0.1);(2, -0.1);(3, -0.1); ...
#>  ---                                         
#> 125:  [6]: (1,-0.04);(2,-0.04);(3,-0.04); ...
#> 126:  [7]: (1, -0.6);(2, -0.6);(3, -0.6); ...
#> 127:  [8]: (1, -0.8);(2, -0.8);(3, -0.8); ...
#> 128:  [9]: (1,-0.05);(2,-0.05);(3,-0.05); ...
#> 129: [10]: (1,  0.1);(2,  0.1);(3,  0.1); ...
#>                                      UVVIS
#>                                  <tfd_reg>
#>   1:  [1]: (1, 0.7);(2, 0.7);(3, 0.7); ...
#>   2:  [2]: (1,-0.9);(2,-0.9);(3,-0.9); ...
#>   3:  [3]: (1,-0.2);(2,-0.2);(3,-0.2); ...
#>   4:  [4]: (1,-0.5);(2,-0.5);(3,-0.5); ...
#>   5:  [5]: (1,-0.8);(2,-0.8);(3,-0.8); ...
#>  ---                                      
#> 125:  [6]: (1,-0.6);(2,-0.6);(3,-0.6); ...
#> 126:  [7]: (1,-0.9);(2,-0.9);(3,-0.9); ...
#> 127:  [8]: (1,-0.8);(2,-0.8);(3,-0.8); ...
#> 128:  [9]: (1, 0.6);(2, 0.6);(3, 0.6); ...
#> 129: [10]: (1,-0.8);(2,-0.8);(3,-0.8); ...
```
