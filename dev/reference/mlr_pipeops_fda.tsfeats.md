# Time Series Feature Extraction

This `PipeOp` extracts time series features from functional columns.

For more details, see
[`tsfeatures::tsfeatures()`](http://pkg.robjhyndman.com/tsfeatures/reference/tsfeatures.md),
which is called internally.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html),
as well as the following parameters:

- `features` :: [`character()`](https://rdrr.io/r/base/character.html)  
  Function names which return numeric vectors of features. All features
  returned by these functions must be named if they return more than one
  feature. Default is
  `c("frequency", "stl_features", "entropy", "acf_features")`.

- `scale` :: `logical(1)`  
  If `TRUE`, data is scaled to mean 0 and sd 1 before features are
  computed. Default is `TRUE`.

- `trim` :: `logical(1)`  
  If `TRUE`, data is trimmed by `trim_amount` before features are
  computed. Values larger than `trim_amount` in absolute value are set
  to `NA`. Default is `FALSE`.

- `trim_amount` :: `numeric(1)`  
  Default level of trimming. Default is `0.1`.

- `parallel` :: `logical(1)`  
  If `TRUE`, the features are computed in parallel. Default is `FALSE`.

- `multiprocess` :: `any`  
  The function from the future package to use for parallel processing.
  Default is
  [`future::multisession()`](https://future.futureverse.org/reference/multisession.html).

- `na.action` :: `any`  
  A function to handle missing values. Default is
  [`stats::na.pass()`](https://rdrr.io/r/stats/na.fail.html).

## Naming

The new names generally append a `_{feature}` to the corresponding
column name. If a column was called `"x"` and the feature is `"trend"`,
the corresponding new column will be called `"x_trend"`.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDATsfeatures`

## Methods

### Public methods

- [`PipeOpFDATsfeatures$new()`](#method-PipeOpFDATsfeatures-new)

- [`PipeOpFDATsfeatures$clone()`](#method-PipeOpFDATsfeatures-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDATsfeatures$new(id = "fda.tsfeats", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default is `"fda.tsfeats"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDATsfeatures$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
po_tsfeats = po("fda.tsfeats")
task_tsfeats = po_tsfeats$train(list(task))[[1L]]
task_tsfeats$data()
#>       heatan    h2o NIR_frequency NIR_nperiods NIR_seasonal_period NIR_trend
#>        <num>  <num>         <num>        <num>               <num>     <num>
#>   1: 26.7810 2.3000             1            0                   1 0.9546922
#>   2: 27.4720 3.0000             1            0                   1 0.9515743
#>   3: 23.8400 2.0002             1            0                   1 0.4707549
#>   4: 18.1680 1.8500             1            0                   1 0.4779991
#>   5: 17.5170 2.3898             1            0                   1 0.9507122
#>  ---                                                                        
#> 125: 23.8340 2.1100             1            0                   1 0.8778792
#> 126: 11.8050 1.6200             1            0                   1 0.9854779
#> 127:  8.8315 1.4200             1            0                   1 0.9887717
#> 128: 11.3450 1.4800             1            0                   1 0.9562442
#> 129: 28.9940 2.5000             1            0                   1 0.8044784
#>         NIR_spike NIR_linearity NIR_curvature  NIR_e_acf1 NIR_e_acf10
#>             <num>         <num>         <num>       <num>       <num>
#>   1: 5.092984e-07      1.500377   -14.8389900  0.08526800  0.13922801
#>   2: 6.047324e-07     13.551188    -5.1228861  0.04333781  0.06594578
#>   3: 9.909298e-05     -8.992664    -3.7895780 -0.36900748  0.29693031
#>   4: 4.928023e-05      6.689307    -3.8887742 -0.10463336  0.19071080
#>   5: 6.500488e-07     14.045622    -4.3742672  0.18067626  0.09144276
#>  ---                                                                 
#> 125: 5.229296e-06     14.009846    -3.3695527  0.15252180  0.18735242
#> 126: 3.639621e-08     15.134587    -0.2588765  0.19727503  0.20779722
#> 127: 3.976177e-08     15.038312    -0.1175876  0.43423412  0.27618845
#> 128: 5.638686e-07     11.562683    -8.9000714  0.18090095  0.09866772
#> 129: 7.539249e-06    -12.302347    -4.8001860 -0.19585687  0.08648780
#>      NIR_entropy NIR_x_acf1 NIR_x_acf10 NIR_diff1_acf1 NIR_diff1_acf10
#>            <num>      <num>       <num>          <num>           <num>
#>   1:   0.4354773  0.9069888   6.3605955     -0.2832035      0.37528302
#>   2:   0.2939412  0.9448758   7.8253925     -0.4984864      0.36126344
#>   3:   0.6530189  0.2826531   2.0955036     -0.7039771      0.72744609
#>   4:   0.8348614  0.3648791   0.8041568     -0.5993595      0.72452181
#>   5:   0.3665353  0.9154091   6.6681478     -0.3014810      0.14010207
#>  ---                                                                  
#> 125:   0.3783612  0.8836760   5.9622264     -0.2487911      0.26465533
#> 126:   0.2542462  0.9616638   7.7381442     -0.5169663      0.65119007
#> 127:   0.0923419  0.9692264   7.7931485     -0.2257876      0.06959872
#> 128:   0.3504391  0.9495463   7.8098652     -0.3017364      0.17580374
#> 129:   0.2084854  0.7670506   5.7345844     -0.5114536      0.29116684
#>      NIR_diff2_acf1 NIR_diff2_acf10 UVVIS_frequency UVVIS_nperiods
#>               <num>           <num>           <num>          <num>
#>   1:     -0.5342972       0.6742914               1              0
#>   2:     -0.6633171       0.5959168               1              0
#>   3:     -0.7866512       0.9116270               1              0
#>   4:     -0.7539921       1.1019418               1              0
#>   5:     -0.6114086       0.4473425               1              0
#>  ---                                                              
#> 125:     -0.5366052       0.5611325               1              0
#> 126:     -0.7609619       1.1970879               1              0
#> 127:     -0.6044396       0.4192549               1              0
#> 128:     -0.6131724       0.5282163               1              0
#> 129:     -0.6604822       0.4903499               1              0
#>      UVVIS_seasonal_period UVVIS_trend  UVVIS_spike UVVIS_linearity
#>                      <num>       <num>        <num>           <num>
#>   1:                     1   0.9392390 1.503863e-06       10.552105
#>   2:                     1   0.8320405 2.371308e-05        9.967401
#>   3:                     1   0.7324108 1.782489e-05        8.067557
#>   4:                     1   0.6591754 3.880087e-05        7.817542
#>   5:                     1   0.7990575 2.365003e-05        9.251109
#>  ---                                                               
#> 125:                     1   0.4516040 9.644443e-05        6.383468
#> 126:                     1   0.6914674 3.511260e-05        2.346512
#> 127:                     1   0.8352613 8.696230e-06        1.220885
#> 128:                     1   0.8974968 5.003478e-06        3.381766
#> 129:                     1   0.7180091 6.170982e-05        9.689281
#>      UVVIS_curvature UVVIS_e_acf1 UVVIS_e_acf10 UVVIS_entropy UVVIS_x_acf1
#>                <num>        <num>         <num>         <num>        <num>
#>   1:       3.7969671   0.06234423    0.14352149     0.3430382    0.9268348
#>   2:       2.9073728  -0.12952783    0.08974614     0.4686135    0.8322983
#>   3:       1.6726579  -0.12604541    0.15486072     0.6220675    0.6844840
#>   4:       4.5641515  -0.21621644    0.12689752     0.6280994    0.5695714
#>   5:       3.9977271  -0.29746795    0.18589166     0.2662301    0.7274064
#>  ---                                                                      
#> 125:       3.7901989  -0.01400302    0.07658932     0.6899361    0.4432345
#> 126:       7.9806922  -0.21722795    0.16418124     0.6601140    0.5810357
#> 127:       9.8332792  -0.30735123    0.28247539     0.3755616    0.7721900
#> 128:       9.2982058  -0.18280897    0.07571742     0.4438987    0.8695996
#> 129:       0.3354961  -0.19728333    0.18618097     0.4433417    0.6908904
#>      UVVIS_x_acf10 UVVIS_diff1_acf1 UVVIS_diff1_acf10 UVVIS_diff2_acf1
#>              <num>            <num>             <num>            <num>
#>   1:      7.025376       -0.3361110         0.3484453       -0.4994596
#>   2:      5.930650       -0.4541526         0.3318020       -0.6050046
#>   3:      3.739534       -0.4730931         0.3110636       -0.6450409
#>   4:      3.620160       -0.6062612         0.5471917       -0.7394589
#>   5:      4.917010       -0.6055341         0.5175728       -0.6662655
#>  ---                                                                  
#> 125:      1.452620       -0.4243995         0.2306197       -0.5893079
#> 126:      3.120828       -0.5156116         0.5919048       -0.6730118
#> 127:      4.787938       -0.6121137         0.6976292       -0.6873167
#> 128:      6.199741       -0.5181048         0.3134932       -0.6955121
#> 129:      4.286336       -0.4140705         0.3492405       -0.5288576
#>      UVVIS_diff2_acf10
#>                  <num>
#>   1:         0.5223420
#>   2:         0.6000084
#>   3:         0.5107427
#>   4:         0.8566489
#>   5:         0.6403891
#>  ---                  
#> 125:         0.3937492
#> 126:         1.0841297
#> 127:         0.9018225
#> 128:         0.6023695
#> 129:         0.5288989
```
