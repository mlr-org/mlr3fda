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
#>       heatan    h20
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
#>                                                                                         NIR
#>                                                                                   <tfd_reg>
#>   1:                   0.2340554,0.2904143,0.2985390,0.2857719,0.4317163,0.4128493,...[231]
#>   2:                   0.2438254,0.3175793,0.1569265,0.3040594,0.2788988,0.2041318,...[231]
#>   3:       -0.05197412, 0.04500882,-0.07834500, 0.12620942,-0.09833023, 0.02935566,...[231]
#>   4: -0.081765370,-0.082304927, 0.058605750,-0.024858584,-0.006321834,-0.060674486,...[231]
#>   5:       -0.22812462,-0.11606918,-0.04202395,-0.11545658,-0.08707948,-0.07724899,...[231]
#>  ---                                                                                       
#> 125: -0.036677545,-0.022985177,-0.061758800,-0.064472334, 0.003787266, 0.013341814,...[231]
#> 126:             -0.6298321,-0.5693807,-0.6526985,-0.5576706,-0.5950987,-0.5608432,...[231]
#> 127:             -0.7318596,-0.8153782,-0.8011885,-0.7131156,-0.7716812,-0.7441482,...[231]
#> 128:       -0.05811752,-0.04569275,-0.00528125,-0.02657358,-0.13537198,-0.07541799,...[231]
#> 129:             0.10433463,0.11665357,0.17538400,0.09664192,0.16000127,0.15103676,...[231]
#>                                                                                 UVVIS
#>                                                                             <tfd_reg>
#>   1:             0.8743160,0.7481823,0.7738064,0.7471426,0.5223545,0.8142814,...[134]
#>   2:       -0.8551739,-1.2873925,-0.8328261,-0.9758280,-0.7976276,-0.9203199,...[134]
#>   3: -0.08469889,-0.29369554,-0.20151308,-0.26229300,-0.27280263,-0.31936488,...[134]
#>   4:       -0.5821539,-0.4851725,-0.3282551,-0.5389530,-0.4092186,-0.3816549,...[134]
#>   5:       -0.6435039,-1.1232725,-0.6649561,-0.7912230,-0.7875426,-0.7048599,...[134]
#>  ---                                                                                 
#> 125:       -0.5410239,-0.6731825,-0.5898611,-0.4922130,-0.7685726,-0.4825299,...[134]
#> 126:       -0.9610539,-0.8193925,-1.0801311,-0.8345630,-0.8032476,-0.6774949,...[134]
#> 127:       -0.8867289,-0.6289675,-0.9939461,-0.6830530,-0.9279676,-0.7833399,...[134]
#> 128:             0.5159331,0.5713029,0.6108473,0.5342805,0.6325831,0.7383201,...[134]
#> 129:       -0.5392589,-1.3016675,-0.7902711,-0.7808930,-0.5305326,-0.7518349,...[134]
```
