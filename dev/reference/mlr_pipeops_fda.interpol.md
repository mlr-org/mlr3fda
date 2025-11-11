# Interpolate Functional Columns

Interpolate functional features (e.g. all individuals are observed at
different time-points) to a common grid. This is useful if you want to
compare functional features across observations. The interpolation is
done using the `tf` package. See
[`tfd()`](https://tidyfun.github.io/tf/reference/tfd.html) for details.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html),
as well as the following parameters:

- `grid` :: `character(1)` \|
  [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  The grid to use for interpolation. If `grid` is numeric, it must be a
  sequence of values to use for the grid or a single value that
  specifies the number of points to use for the grid, requires `left`
  and `right` to be specified in the latter case. If `grid` is a
  character, it must be one of:

  - `"union"`: This option creates a grid based on the union of all
    argument points from the provided functional features. This means
    that if the argument points across features are \\t_1, t_2, ...,
    t_n\\, then the grid will be the combined unique set of these
    points. This option is generally used when the argument points vary
    across observations and a common grid is needed for comparison or
    further analysis.

  - `"intersect"`: Creates a grid using the intersection of all argument
    points of a feature. This grid includes only those points that are
    common across all functional features, facilitating direct
    comparison on a shared set of points.

  - `"minmax"`: Generates a grid within the range of the maximum of the
    minimum argument points to the minimum of the maximum argument
    points across features. This bounded grid encapsulates the argument
    point range common to all features. Note: For regular functional
    data this has no effect as all argument points are the same. Initial
    value is `"union"`.

- `method` :: `character(1)`  
  Defaults to `"linear"`. One of:

  - `"linear"`: applies linear interpolation without extrapolation (see
    [`tf::tf_approx_linear()`](https://tidyfun.github.io/tf/reference/tf_approx.html)).

  - `"spline"`: applies cubic spline interpolation (see
    [`tf::tf_approx_spline()`](https://tidyfun.github.io/tf/reference/tf_approx.html)).

  - `"fill_extend"`: applies linear interpolation with constant
    extrapolation (see
    [`tf::tf_approx_fill_extend()`](https://tidyfun.github.io/tf/reference/tf_approx.html)).

  - `"locf"`: applies "last observation carried forward" interpolation
    (see
    [`tf::tf_approx_locf()`](https://tidyfun.github.io/tf/reference/tf_approx.html)).

  - `"nocb"`: applies "next observation carried backward" interpolation
    (see
    [`tf::tf_approx_nocb()`](https://tidyfun.github.io/tf/reference/tf_approx.html)).

- `left` :: [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  The left boundary of the window. The window is specified such that the
  all values \>=left and \<=right are kept for the computations.

- `right` :: [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  The right boundary of the window.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDAInterpol`

## Methods

### Public methods

- [`PipeOpFDAInterpol$new()`](#method-PipeOpFDAInterpol-new)

- [`PipeOpFDAInterpol$clone()`](#method-PipeOpFDAInterpol-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDAInterpol$new(id = "fda.interpol", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fda.interpol"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDAInterpol$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
pop = po("fda.interpol")
task_interpol = pop$train(list(task))[[1L]]
task_interpol$data()
#>       heatan    h20                                         NIR
#>        <num>  <num>                                   <tfd_reg>
#>   1: 26.7810 2.3000  [1]: (1,   0.2);(2,   0.3);(3,   0.3); ...
#>   2: 27.4720 3.0000  [2]: (1,   0.2);(2,   0.3);(3,   0.2); ...
#>   3: 23.8400 2.0002  [3]: (1, -0.05);(2,  0.05);(3, -0.08); ...
#>   4: 18.1680 1.8500  [4]: (1, -0.08);(2, -0.08);(3,  0.06); ...
#>   5: 17.5170 2.3898  [5]: (1, -0.23);(2, -0.12);(3, -0.04); ...
#>  ---                                                           
#> 125: 23.8340 2.1100  [6]: (1, -0.04);(2, -0.02);(3, -0.06); ...
#> 126: 11.8050 1.6200  [7]: (1,  -0.6);(2,  -0.6);(3,  -0.7); ...
#> 127:  8.8315 1.4200  [8]: (1,  -0.7);(2,  -0.8);(3,  -0.8); ...
#> 128: 11.3450 1.4800  [9]: (1,-0.058);(2,-0.046);(3,-0.005); ...
#> 129: 28.9940 2.5000 [10]: (1,   0.1);(2,   0.1);(3,   0.2); ...
#>                                         UVVIS
#>                                     <tfd_reg>
#>   1:  [1]: (1,  0.9);(2,  0.7);(3,  0.8); ...
#>   2:  [2]: (1, -0.9);(2, -1.3);(3, -0.8); ...
#>   3:  [3]: (1,-0.08);(2,-0.29);(3,-0.20); ...
#>   4:  [4]: (1, -0.6);(2, -0.5);(3, -0.3); ...
#>   5:  [5]: (1, -0.6);(2, -1.1);(3, -0.7); ...
#>  ---                                         
#> 125:  [6]: (1, -0.5);(2, -0.7);(3, -0.6); ...
#> 126:  [7]: (1, -1.0);(2, -0.8);(3, -1.1); ...
#> 127:  [8]: (1, -0.9);(2, -0.6);(3, -1.0); ...
#> 128:  [9]: (1,  0.5);(2,  0.6);(3,  0.6); ...
#> 129: [10]: (1, -0.5);(2, -1.3);(3, -0.8); ...
```
