# Functional Integral Features

Computes the definite integral of functional features via
[`tf::tf_integrate()`](https://tidyfun.github.io/tf/reference/tf_integrate.html).
The integral summarizes each curve into a single scalar, namely the
(signed) area under the curve over its domain.

By default the integral is taken over the full domain of each curve. The
`lower` and `upper` parameters restrict the integration to a window. The
same operation is applied during training and prediction.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html),
as well as the following parameters:

- `lower` :: `numeric(1)`  
  The left boundary of the integration window. If not set, the domain
  start of each curve is used.

- `upper` :: `numeric(1)`  
  The right boundary of the integration window. If not set, the domain
  end of each curve is used.

## Naming

The new names generally append a `_integral` to the corresponding column
name. If a column was called `"x"`, the corresponding new column will be
called `"x_integral"`.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDAIntegrate`

## Methods

### Public methods

- [`PipeOpFDAIntegrate$new()`](#method-PipeOpFDAIntegrate-initialize)

- [`PipeOpFDAIntegrate$clone()`](#method-PipeOpFDAIntegrate-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFDAIntegrate$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDAIntegrate$new(id = "fda.integrate", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fda.integrate"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFDAIntegrate$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDAIntegrate$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
po_integrate = po("fda.integrate")
task_integrate = po_integrate$train(list(task))[[1L]]
task_integrate$data(cols = c("NIR_integral", "UVVIS_integral"))
#>      NIR_integral UVVIS_integral
#>             <num>          <num>
#>   1:   114.935592      127.99948
#>   2:    97.984734     -106.18361
#>   3:     3.084564      -35.23032
#>   4:     4.677446      -61.23096
#>   5:    19.189222      -97.41908
#>  ---                            
#> 125:    27.320455      -73.85921
#> 126:   -56.876993     -124.84087
#> 127:   -77.806418     -140.49484
#> 128:    34.483231       68.42104
#> 129:    29.168967      -78.78329
```
