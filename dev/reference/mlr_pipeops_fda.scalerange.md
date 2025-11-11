# Linearly Transform the Domain of Functional Data

Linearly transform the domain of functional data so they are between
`lower` and `upper`. The formula for this is \\x' = offset + x \*
scale\\, where \\scale\\ is \\(upper - lower) / (max(x) - min(x))\\ and
\\offset\\ is \\-min(x) \* scale + lower\\. The same transformation is
applied during training and prediction.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html),
as well as the following parameters:

- `lower` :: `numeric(1)`  
  Target value of smallest item of input data. Initialized to `0`.

- `uppper` :: `numeric(1)`  
  Target value of greatest item of input data. Initialized to `1`.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\> `PipeOpFDAScaleRange`

## Methods

### Public methods

- [`PipeOpFDAScaleRange$new()`](#method-PipeOpFDAScaleRange-new)

- [`PipeOpFDAScaleRange$clone()`](#method-PipeOpFDAScaleRange-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDAScaleRange$new(id = "fda.scalerange", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fda.scalerange"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDAScaleRange$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
po_scale = po("fda.scalerange", lower = -1, upper = 1)
task_scale = po_scale$train(list(task))[[1L]]
task_scale$data()
#>       heatan    h20                                                        NIR
#>        <num>  <num>                                                  <tfd_reg>
#>   1: 26.7810 2.3000  [1]: (-1.00,   0.23);(-0.99,   0.29);(-0.98,   0.30); ...
#>   2: 27.4720 3.0000  [2]: (-1.00,   0.24);(-0.99,   0.32);(-0.98,   0.16); ...
#>   3: 23.8400 2.0002  [3]: (-1.00, -0.052);(-0.99,  0.045);(-0.98, -0.078); ...
#>   4: 18.1680 1.8500  [4]: (-1.00, -0.082);(-0.99, -0.082);(-0.98,  0.059); ...
#>   5: 17.5170 2.3898  [5]: (-1.00, -0.228);(-0.99, -0.116);(-0.98, -0.042); ...
#>  ---                                                                          
#> 125: 23.8340 2.1100  [6]: (-1.00, -0.037);(-0.99, -0.023);(-0.98, -0.062); ...
#> 126: 11.8050 1.6200  [7]: (-1.00,  -0.63);(-0.99,  -0.57);(-0.98,  -0.65); ...
#> 127:  8.8315 1.4200  [8]: (-1.00,  -0.73);(-0.99,  -0.82);(-0.98,  -0.80); ...
#> 128: 11.3450 1.4800  [9]: (-1.00,-0.0581);(-0.99,-0.0457);(-0.98,-0.0053); ...
#> 129: 28.9940 2.5000 [10]: (-1.00,   0.10);(-0.99,   0.12);(-0.98,   0.18); ...
#>                                                        UVVIS
#>                                                    <tfd_reg>
#>   1:  [1]: (-1.00,  0.87);(-0.98,  0.75);(-0.97,  0.77); ...
#>   2:  [2]: (-1.00, -0.86);(-0.98, -1.29);(-0.97, -0.83); ...
#>   3:  [3]: (-1.00,-0.085);(-0.98,-0.294);(-0.97,-0.202); ...
#>   4:  [4]: (-1.00, -0.58);(-0.98, -0.49);(-0.97, -0.33); ...
#>   5:  [5]: (-1.00, -0.64);(-0.98, -1.12);(-0.97, -0.66); ...
#>  ---                                                        
#> 125:  [6]: (-1.00, -0.54);(-0.98, -0.67);(-0.97, -0.59); ...
#> 126:  [7]: (-1.00, -0.96);(-0.98, -0.82);(-0.97, -1.08); ...
#> 127:  [8]: (-1.00, -0.89);(-0.98, -0.63);(-0.97, -0.99); ...
#> 128:  [9]: (-1.00,  0.52);(-0.98,  0.57);(-0.97,  0.61); ...
#> 129: [10]: (-1.00, -0.54);(-0.98, -1.30);(-0.97, -0.79); ...
```
