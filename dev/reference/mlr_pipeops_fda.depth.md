# Functional Data Depth Features

Computes the data depth of functional features via
[`tf::tf_depth()`](https://tidyfun.github.io/tf/reference/tf_depth.html).
Data depth measures how central each curve is relative to the others:
values close to `1` indicate central curves and values close to `0`
indicate extreme curves.

The depth is computed in-sample, i.e. each curve is scored relative to
the other curves in the same data. The same operation is applied during
training and prediction.

Irregular curves are interpolated to a common grid before the depth is
computed. Curves that remain incomplete after interpolation (e.g.
because they only cover part of the grid) are assigned a depth of `NA`.

## Details

The `"MHI"` method ranks functions from lowest (`0`) to highest (`1`)
instead of from most extreme to most central. The `"RPD"` method relies
on random projections, so set a seed (e.g. via
[`set.seed()`](https://rdrr.io/r/base/Random.html)) before training for
reproducible results.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html),
as well as the following parameters:

- `method` :: `character(1)`  
  The depth method to use. One of `"MBD"` (modified band depth, the
  default), `"MHI"` (modified hypograph index), `"FM"` (Fraiman-Muniz),
  `"FSD"` (functional spatial depth), or `"RPD"` (regularized projection
  depth). Initial value is `"MBD"`.

- `na.rm` :: `logical(1)`  
  Whether to remove missing observations before computing the depth.
  Initial value is `TRUE`.

- `u` :: `numeric(1)`  
  Quantile level for the regularization. Only used when `method` is
  `"RPD"`. Default is `0.01`.

- `n_projections` :: `integer(1)`  
  Number of projection directions. Only used when `method` is `"RPD"`.
  Default is `5000`.

- `n_projections_beta` :: `integer(1)`  
  Number of directions for estimating the regularization parameter. Only
  used when `method` is `"RPD"`. Default is `500`.

## Naming

The new names generally append a `_depth` to the corresponding column
name. If a column was called `"x"`, the corresponding new column will be
called `"x_depth"`.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDADepth`

## Methods

### Public methods

- [`PipeOpFDADepth$new()`](#method-PipeOpFDADepth-initialize)

- [`PipeOpFDADepth$clone()`](#method-PipeOpFDADepth-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFDADepth$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDADepth$new(id = "fda.depth", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fda.depth"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFDADepth$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDADepth$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
po_depth = po("fda.depth", method = "MBD")
task_depth = po_depth$train(list(task))[[1L]]
task_depth$data(cols = c("NIR_depth", "UVVIS_depth"))
#>       NIR_depth UVVIS_depth
#>           <num>       <num>
#>   1: 0.06086641  0.18607019
#>   2: 0.12161695  0.31235155
#>   3: 1.00176051  0.88750310
#>   4: 0.96914866  0.68872490
#>   5: 0.75128286  0.38775354
#>  ---                       
#> 125: 0.66711535  0.57225367
#> 126: 0.45788517  0.17058908
#> 127: 0.34026479  0.09003249
#> 128: 0.56095330  0.56875747
#> 129: 0.65649751  0.54263748
```
