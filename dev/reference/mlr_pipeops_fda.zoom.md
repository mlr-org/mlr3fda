# Zoom In/Out on Functional Columns

Zoom in or out on functional features by restricting their domain to a
specified window. This operation extracts a subset of each function by
defining new lower and upper boundaries, effectively cropping the
functional data to focus on a specific region of interest. Calls
[`tf::tf_zoom()`](https://tidyfun.github.io/tf/reference/tf_zoom.html)
from package [tf](https://CRAN.R-project.org/package=tf).

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html),
as well as the following parameters:

- `begin` :: [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  The lower limit of the domain. Can be a single value applied to all
  functional columns, or a numeric of length equal to the number of
  observations. The window includes all values where argument \>=
  `begin`. If not specified, defaults to the lower limit of each
  function's domain.

- `end` :: [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  The upper limit of the domain.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDAZoom`

## Methods

### Public methods

- [`PipeOpFDAZoom$new()`](#method-PipeOpFDAZoom-new)

- [`PipeOpFDAZoom$clone()`](#method-PipeOpFDAZoom-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDAZoom$new(id = "fda.zoom", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fda.zoom"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDAZoom$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
pop = po("fda.zoom", begin = 50, end = 100)
task_zoom = pop$train(list(task))[[1L]]
task_zoom$data()
#>       heatan    h20                                            NIR
#>        <num>  <num>                                      <tfd_reg>
#>   1: 26.7810 2.3000  [1]: (50,   0.5);(51,   0.5);(52,   0.5); ...
#>   2: 27.4720 3.0000  [2]: (50,   0.3);(51,   0.4);(52,   0.4); ...
#>   3: 23.8400 2.0002  [3]: (50,  0.04);(51,  0.04);(52,  0.04); ...
#>   4: 18.1680 1.8500  [4]: (50, 0.014);(51, 0.024);(52,-0.009); ...
#>   5: 17.5170 2.3898  [5]: (50,  0.03);(51,  0.05);(52,  0.03); ...
#>  ---                                                              
#> 125: 23.8340 2.1100  [6]: (50,  0.09);(51,  0.08);(52,  0.06); ...
#> 126: 11.8050 1.6200  [7]: (50,  -0.4);(51,  -0.4);(52,  -0.4); ...
#> 127:  8.8315 1.4200  [8]: (50,  -0.6);(51,  -0.5);(52,  -0.6); ...
#> 128: 11.3450 1.4800  [9]: (50,  0.09);(51,  0.07);(52,  0.08); ...
#> 129: 28.9940 2.5000 [10]: (50,   0.2);(51,   0.2);(52,   0.2); ...
#>                                         UVVIS
#>                                     <tfd_reg>
#>   1:  [1]: (50, 0.8);(51, 0.8);(52, 0.8); ...
#>   2:  [2]: (50,-1.0);(51,-0.9);(52,-0.9); ...
#>   3:  [3]: (50,-0.3);(51,-0.3);(52,-0.3); ...
#>   4:  [4]: (50,-0.6);(51,-0.6);(52,-0.5); ...
#>   5:  [5]: (50,-0.9);(51,-0.9);(52,-0.9); ...
#>  ---                                         
#> 125:  [6]: (50,-0.6);(51,-0.6);(52,-0.6); ...
#> 126:  [7]: (50,  -1);(51,  -1);(52,  -1); ...
#> 127:  [8]: (50,  -1);(51,  -1);(52,  -1); ...
#> 128:  [9]: (50, 0.4);(51, 0.4);(52, 0.4); ...
#> 129: [10]: (50,-0.7);(51,-0.7);(52,-0.7); ...
```
