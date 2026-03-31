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

- `upper` :: `numeric(1)`  
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
