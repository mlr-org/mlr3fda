# Extracts Simple Features from Functional Columns

This is the class that extracts simple features from functional columns.
Note that it only operates on values that were actually observed and
does not interpolate.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html),
as well as the following parameters:

- `drop` :: `logical(1)`  
  Whether to drop the original `functional` features and only keep the
  extracted features. Note that this does not remove the features from
  the backend, but only from the active column role `feature`. Initial
  value is `TRUE`.

- `features` :: [`list()`](https://rdrr.io/r/base/list.html) \|
  [`character()`](https://rdrr.io/r/base/character.html)  
  A list of features to extract. Each element can be either a function
  or a string. If the element is a function it requires the following
  arguments: `arg` and `value` and returns a `numeric`. For string
  elements, the following predefined features are available: `"mean"`,
  `"max"`,`"min"`,`"slope"`,`"median"`,`"var"`. Initial is
  `c("mean", "max", "min", "slope", "median", "var")`

- `left` :: [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  The left boundary of the window. Initial is `-Inf`. The window is
  specified such that the all values \>=left and \<=right are kept for
  the computations.

- `right` :: [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  The right boundary of the window. Initial is `Inf`.

## Naming

The new names generally append a `_{feature}` to the corresponding
column name. However this can lead to name clashes with existing
columns. This is solved as follows: If a column was called `"x"` and the
feature is `"mean"`, the corresponding new column will be called
`"x_mean"`. In case of duplicates, unique names are obtained using
[`make.unique()`](https://rdrr.io/r/base/make.unique.html) and a warning
is given.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDAExtract`

## Methods

### Public methods

- [`PipeOpFDAExtract$new()`](#method-PipeOpFDAExtract-new)

- [`PipeOpFDAExtract$clone()`](#method-PipeOpFDAExtract-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDAExtract$new(id = "fda.extract", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default is `"fda.extract"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDAExtract$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
po_fmean = po("fda.extract", features = "mean")
task_fmean = po_fmean$train(list(task))[[1L]]

# add more than one feature
pop = po("fda.extract", features = c("mean", "median", "var"))
task_features = pop$train(list(task))[[1L]]

# add a custom feature
po_custom = po("fda.extract",
  features = list(mean = function(arg, value) mean(value, na.rm = TRUE))
)
task_custom = po_custom$train(list(task))[[1L]]
task_custom
#> 
#> ── <TaskRegr> (129x4): Spectral Data of Fossil Fuels ───────────────────────────
#> • Target: heatan
#> • Properties: -
#> • Features (3):
#>   • dbl (3): NIR_mean, UVVIS_mean, h2o
```
