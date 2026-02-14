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
#>       heatan    h2o
#>        <num>  <num>
#>   1: 26.7810 2.3000
#>   2: 27.4720 3.0000
#>   3: 23.8400 2.0002
#>   4: 18.1680 1.8500
#>   5: 17.5170 2.3898
#>  ---               
#> 125: 23.8340 2.1100
#> 126: 11.8050 1.6200
#> 127:  8.8315 1.4200
#> 128: 11.3450 1.4800
#> 129: 28.9940 2.5000
#>                                                                                              NIR
#>                                                                                        <tfd_reg>
#>   1:                         0.4903712,0.4872571,0.5080805,0.5005618,0.5124714,0.4948048,...[51]
#>   2:                         0.3362445,0.3710856,0.3692587,0.3589461,0.3603959,0.3721286,...[51]
#>   3:                   0.03834625,0.04085961,0.04100549,0.02633183,0.03251635,0.02922484,...[51]
#>   4:  0.0135412467, 0.0244696143,-0.0092595097,-0.0003681676, 0.0035713527, 0.0127448442,...[51]
#>   5:                   0.02623625,0.05446461,0.02543799,0.03316683,0.02886385,0.04772234,...[51]
#>  ---                                                                                            
#> 125:                   0.08794875,0.08197211,0.05977799,0.08401933,0.08655135,0.09346734,...[51]
#> 126:                   -0.4334763,-0.4214279,-0.3967620,-0.4067932,-0.4042486,-0.4149027,...[51]
#> 127:                   -0.5556038,-0.5349204,-0.5643920,-0.5305882,-0.5186886,-0.5570602,...[51]
#> 128:                   0.08914625,0.06708711,0.08032549,0.04103183,0.05668885,0.07351484,...[51]
#> 129:                         0.1830305,0.1502646,0.1556462,0.1678938,0.1480964,0.1481573,...[51]
#>                                                                          UVVIS
#>                                                                      <tfd_reg>
#>   1:       0.7848743,0.7872711,0.7789112,0.7871670,0.7826240,0.8176640,...[51]
#>   2: -0.9545992,-0.9428285,-0.9226017,-0.9283782,-0.8945372,-0.9486111,...[51]
#>   3: -0.2947142,-0.2965735,-0.3182067,-0.2936832,-0.2844072,-0.2997761,...[51]
#>   4: -0.5881392,-0.5516085,-0.5247567,-0.5681932,-0.5500672,-0.5270461,...[51]
#>   5: -0.8580342,-0.8632585,-0.8584017,-0.8489332,-0.8423522,-0.8334511,...[51]
#>  ---                                                                          
#> 125: -0.5983242,-0.6057285,-0.5967367,-0.5878032,-0.6231672,-0.6256761,...[51]
#> 126:       -1.035104,-1.034348,-1.042407,-1.041253,-1.037712,-1.050781,...[51]
#> 127:       -1.230214,-1.222768,-1.206467,-1.223283,-1.220437,-1.229056,...[51]
#> 128:       0.3839528,0.3788025,0.3738073,0.3827753,0.3719683,0.3581329,...[51]
#> 129: -0.6961642,-0.6768985,-0.6543117,-0.6778032,-0.6372072,-0.6398161,...[51]
```
