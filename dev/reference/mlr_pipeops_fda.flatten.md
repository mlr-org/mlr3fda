# Flattens Functional Columns

Convert regular functional features (e.g. all individuals are observed
at the same time-points) to new columns, one for each input value to the
function.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html).

## Naming

The new names generally append a `_1`, ..., to the corresponding column
name. However this can lead to name clashes with existing columns. This
is solved as follows: If a column was called `"x"`, the corresponding
new columns will be called `"x_1"`, `"x_2"`, etc. In case of duplicates,
unique names are obtained using
[`make.unique()`](https://rdrr.io/r/base/make.unique.html) and a warning
is given.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDAFlatten`

## Methods

### Public methods

- [`PipeOpFDAFlatten$new()`](#method-PipeOpFDAFlatten-new)

- [`PipeOpFDAFlatten$clone()`](#method-PipeOpFDAFlatten-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDAFlatten$new(id = "fda.flatten", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fda.flatten"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDAFlatten$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
pop = po("fda.flatten")
task_flat = pop$train(list(task))
```
