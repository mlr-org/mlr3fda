# Functional Principal Component Analysis

This `PipeOp` applies a functional principal component analysis (FPCA)
to functional columns and then extracts the principal components as
features. This is done using a (truncated) weighted SVD.

To apply this `PipeOp` to irregular data, convert it to a regular grid
first using
[`PipeOpFDAInterpol`](https://mlr3fda.mlr-org.com/dev/reference/mlr_pipeops_fda.interpol.md).

For more details, see
[`tf::tfb_fpc()`](https://tidyfun.github.io/tf/reference/tfb_fpc.html),
which is called internally.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html),
as well as the following parameters:

- `pve` :: `numeric(1)`  
  The percentage of variance explained that should be retained. Default
  is `0.995`.

- `n_components` :: `integer(1)`  
  The number of principal components to extract. This parameter is
  initialized to `Inf`.

## Naming

The new names generally append a `_pc_{number}` to the corresponding
column name. If a column was called `"x"` and there are three principal
components, the corresponding new columns will be called
`"x_pc_1", "x_pc_2", "x_pc_3"`.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\> `PipeOpFPCA`

## Methods

### Public methods

- [`PipeOpFPCA$new()`](#method-PipeOpFPCA-new)

- [`PipeOpFPCA$clone()`](#method-PipeOpFPCA-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFPCA$new(id = "fda.fpca", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default is `"fda.fpca"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFPCA$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
po_fpca = po("fda.fpca", n_components = 3L)
task_fpca = po_fpca$train(list(task))[[1L]]
task_fpca$data()
#>       heatan    h20   NIR_pc_1   NIR_pc_2     NIR_pc_3 UVVIS_pc_1 UVVIS_pc_2
#>        <num>  <num>      <num>      <num>        <num>      <num>      <num>
#>   1: 26.7810 2.3000  7.5675043  1.1371827 -0.377501250  11.000976 -2.7804661
#>   2: 27.4720 3.0000  6.2793462  1.9345782  0.160548831  -9.298016 -1.7955553
#>   3: 23.8400 2.0002  0.2348390 -0.1721228 -0.024101132  -3.078812 -0.6114645
#>   4: 18.1680 1.8500  0.2913332  0.2052379  0.040952119  -5.349049 -0.7030112
#>   5: 17.5170 2.3898  1.1406877  1.2563331  0.001074654  -8.497281 -1.2413718
#>  ---                                                                        
#> 125: 23.8340 2.1100  1.6980728  0.9841985  0.041623661  -6.427319 -0.2898928
#> 126: 11.8050 1.6200 -4.0420811  2.2340299 -0.029562942 -10.843930 -0.0918478
#> 127:  8.8315 1.4200 -5.5013835  2.8333813 -0.034304440 -12.227632 -0.1838102
#> 128: 11.3450 1.4800  2.1809306  1.4395300 -0.397523197   5.871679 -1.0021267
#> 129: 28.9940 2.5000  1.9734804 -0.1998806  0.034337704  -6.893096 -1.4463943
#>       UVVIS_pc_3
#>            <num>
#>   1:  0.13667224
#>   2: -0.46762503
#>   3: -0.27479445
#>   4:  0.08631440
#>   5: -0.19140105
#>  ---            
#> 125: -0.02865269
#> 126:  0.56113685
#> 127:  1.11134683
#> 128:  1.01323166
#> 129: -0.81054907
```
