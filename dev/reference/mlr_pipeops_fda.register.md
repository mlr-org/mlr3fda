# Register (Align) Functional Columns

Aligns functional features by estimating warping functions against a
template using
[`tf::tf_register()`](https://tidyfun.github.io/tf/reference/tf_register.html).
Registration reduces phase (horizontal) variability while preserving
amplitude (vertical) variability, which is useful when curves share a
common shape but differ in the timing of their features.

During training, a template is learned for each functional column
(either estimated iteratively from the data or supplied via `args`). The
template is stored as part of the `$state` and reused at predict time so
that new observations are aligned to the same reference as the training
data.

Supported methods are `"srvf"`, `"cc"`, and `"affine"`. The `"landmark"`
method from
[`tf::tf_register()`](https://tidyfun.github.io/tf/reference/tf_register.html)
is not supported because it requires per-observation landmark positions
for both training and prediction data, which does not fit a stateful
preprocessing step. For landmark registration, use
[`tf::tf_register()`](https://tidyfun.github.io/tf/reference/tf_register.html)
directly and feed the aligned data into the task.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html),
as well as the following parameters:

- `method` :: `character(1)`  
  Registration method. One of:

  - `"srvf"`: elastic registration using the Square Root Velocity
    Framework via `fdasrvf::time_warping()`. Requires regular grids and
    the [fdasrvf](https://CRAN.R-project.org/package=fdasrvf) package.
    Default template is the Karcher mean.

  - `"cc"`: continuous-criterion registration with monotone spline
    warps. Requires regular grids. Default template is the arithmetic
    mean.

  - `"affine"`: affine (shift and/or scale) registration with warps of
    the form \\h(t) = a \cdot t + b\\. Supports regular and irregular
    grids. Default template is the arithmetic mean.

  Default is `"srvf"`.

- `args` :: named [`list()`](https://rdrr.io/r/base/list.html)  
  Method-specific arguments passed to
  [`tf::tf_register()`](https://tidyfun.github.io/tf/reference/tf_register.html)
  via `...`. See the help page of
  [`tf::tf_estimate_warps()`](https://tidyfun.github.io/tf/reference/tf_estimate_warps.html)
  for valid arguments (e.g. `lambda` / `penalty_method` for `"srvf"`;
  `nbasis`, `lambda`, `crit`, `conv`, `iterlim` for `"cc"`; `type`,
  `shift_range`, `scale_range` for `"affine"`). An optional `template`
  entry is honored at training time and stored in the state.

- `max_iter` :: `integer(1)`  
  Maximum number of Procrustes-style template refinement iterations
  during training. Default is `3`. Ignored at predict time because the
  stored template is used directly.

- `tol` :: `numeric(1)`  
  Convergence tolerance for template refinement during training. Default
  is `0.01`.

## State

`$state$templates` contains the learned template (as a length-1 `tf`
vector) for each functional column.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\> `PipeOpFDARegister`

## Methods

### Public methods

- [`PipeOpFDARegister$new()`](#method-PipeOpFDARegister-initialize)

- [`PipeOpFDARegister$clone()`](#method-PipeOpFDARegister-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFDARegister$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDARegister$new(id = "fda.register", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fda.register"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFDARegister$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDARegister$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# \donttest{
set.seed(1)
task = tsk("fuel")
po_reg = po("fda.register", method = "affine", args = list(type = "shift_scale"))
task_reg = po_reg$train(list(task))[[1L]]
#> Warning: 2 `NA` entries (empty functions) created.
#> ℹ Affected indices: 54, 57
#> This happened in PipeOp fda.register's $train()
#> Warning: ℹ 4888 evaluations were `NA`
#> ✖ Returning irregular <tfd>.
#> This happened in PipeOp fda.register's $train()
#> Warning: 2 `NA` entries (empty functions) created.
#> ℹ Affected indices: 54, 57
#> This happened in PipeOp fda.register's $train()
#> Warning: 1 `NA` entry (empty function) created.
#> ℹ Affected index: 57
#> This happened in PipeOp fda.register's $train()
#> Warning: ℹ 4942 evaluations were `NA`
#> ✖ Returning irregular <tfd>.
#> This happened in PipeOp fda.register's $train()
#> Warning: 1 `NA` entry (empty function) created.
#> ℹ Affected index: 57
#> This happened in PipeOp fda.register's $train()
#> Iterative registration stopped after 1 of 3 iterations: alignment worsened
#> (objective 0.0099 > 0.0066).
#> Warning: 2 `NA` entries (empty functions) created.
#> ℹ Affected indices: 54, 57
#> This happened in PipeOp fda.register's $train()
#> Warning: ℹ 4888 evaluations were `NA`
#> ✖ Returning irregular <tfd>.
#> This happened in PipeOp fda.register's $train()
#> Warning: 2 `NA` entries (empty functions) created.
#> ℹ Affected indices: 54, 57
#> This happened in PipeOp fda.register's $train()
#> Warning: 6 `NA` entries (empty functions) created.
#> ℹ Affected indices: 43, 83, 92, 94, 97, 102
#> This happened in PipeOp fda.register's $train()
#> Warning: ℹ 5239 evaluations were `NA`
#> ✖ Returning irregular <tfd>.
#> This happened in PipeOp fda.register's $train()
#> Warning: 6 `NA` entries (empty functions) created.
#> ℹ Affected indices: 43, 83, 92, 94, 97, 102
#> This happened in PipeOp fda.register's $train()
#> Warning: 5 `NA` entries (empty functions) created.
#> ℹ Affected indices: 83, 92, 94, 97, 106
#> This happened in PipeOp fda.register's $train()
#> Warning: ℹ 5341 evaluations were `NA`
#> ✖ Returning irregular <tfd>.
#> This happened in PipeOp fda.register's $train()
#> Warning: 5 `NA` entries (empty functions) created.
#> ℹ Affected indices: 83, 92, 94, 97, 106
#> This happened in PipeOp fda.register's $train()
#> Warning: 7 `NA` entries (empty functions) created.
#> ℹ Affected indices: 43, 83, 84, 92, 94, 97, 106
#> This happened in PipeOp fda.register's $train()
#> Warning: ℹ 5352 evaluations were `NA`
#> ✖ Returning irregular <tfd>.
#> This happened in PipeOp fda.register's $train()
#> Warning: 7 `NA` entries (empty functions) created.
#> ℹ Affected indices: 43, 83, 84, 92, 94, 97, 106
#> This happened in PipeOp fda.register's $train()
#> Iterative registration stopped after 2 of 3 iterations: alignment worsened
#> (objective 0.9203 > 0.4754).
#> Warning: 5 `NA` entries (empty functions) created.
#> ℹ Affected indices: 83, 92, 94, 97, 106
#> This happened in PipeOp fda.register's $train()
#> Warning: ℹ 5341 evaluations were `NA`
#> ✖ Returning irregular <tfd>.
#> This happened in PipeOp fda.register's $train()
#> Warning: 5 `NA` entries (empty functions) created.
#> ℹ Affected indices: 83, 92, 94, 97, 106
#> This happened in PipeOp fda.register's $train()
task_reg$data(cols = c("NIR", "UVVIS"))
#>              NIR       UVVIS
#>      <tfd_irreg> <tfd_irreg>
#>   1:   <list[2]>   <list[2]>
#>   2:   <list[2]>   <list[2]>
#>   3:   <list[2]>   <list[2]>
#>   4:   <list[2]>   <list[2]>
#>   5:   <list[2]>   <list[2]>
#>  ---                        
#> 125:   <list[2]>   <list[2]>
#> 126:   <list[2]>   <list[2]>
#> 127:   <list[2]>   <list[2]>
#> 128:   <list[2]>   <list[2]>
#> 129:   <list[2]>   <list[2]>
# }
```
