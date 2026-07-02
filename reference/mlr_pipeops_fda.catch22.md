# Catch22 Feature Extraction

This `PipeOp` extracts the 22 (or 24) canonical time series
characteristics (catch22) from functional columns. For more details, see
[`Rcatch22::catch22_all()`](https://rdrr.io/pkg/Rcatch22/man/catch22_all.html),
which is called internally on each curve.

The catch22 set is a low-redundancy subset of the hctsa features,
selected for their performance across a diverse collection of time
series classification tasks, but applicable as general-purpose features
for other tasks such as regression.

For other time series feature extractors, see
[`PipeOpFDATsfeatures`](https://mlr3fda.mlr-org.com/reference/mlr_pipeops_fda.tsfeats.md).

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html),
as well as the following parameters:

- `catch24` :: `logical(1)`  
  If `TRUE`, additionally compute the mean and standard deviation (the
  catch24 set), yielding 24 features instead of 22. Default is `FALSE`.

## Naming

The new names generally append a `_{feature}` to the corresponding
column name. If a column was called `"x"` and the feature is
`"DN_HistogramMode_5"`, the corresponding new column will be called
`"x_DN_HistogramMode_5"`.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDACatch22`

## Methods

### Public methods

- [`PipeOpFDACatch22$new()`](#method-PipeOpFDACatch22-initialize)

- [`PipeOpFDACatch22$clone()`](#method-PipeOpFDACatch22-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFDACatch22$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDACatch22$new(id = "fda.catch22", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fda.catch22"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFDACatch22$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDACatch22$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
po_catch22 = po("fda.catch22")
task_catch22 = po_catch22$train(list(task))[[1L]]
task_catch22$data()
#>       heatan    h2o NIR_DN_HistogramMode_5 NIR_DN_HistogramMode_10
#>        <num>  <num>                  <num>                   <num>
#>   1: 26.7810 2.3000             0.65903335              0.89906525
#>   2: 27.4720 3.0000             0.71703535              0.94042738
#>   3: 23.8400 2.0002             0.02528328              0.46411508
#>   4: 18.1680 1.8500             0.69290569              0.19460477
#>   5: 17.5170 2.3898             0.80525107              0.46384266
#>  ---                                                              
#> 125: 23.8340 2.1100             0.85636136             -0.08530372
#> 126: 11.8050 1.6200             0.27729299              1.03383987
#> 127:  8.8315 1.4200             0.40673933              1.14766493
#> 128: 11.3450 1.4800             0.33106873              1.05249299
#> 129: 28.9940 2.5000             0.07346713              0.36660400
#>      NIR_CO_f1ecac NIR_CO_FirstMin_ac NIR_CO_HistogramAMI_even_2_5
#>              <num>              <num>                        <num>
#>   1:     28.908320                  5                    0.7427983
#>   2:     43.589840                  4                    0.9172264
#>   3:      1.881192                  1                    0.3994337
#>   4:      1.995276                  1                    0.1158634
#>   5:     41.162216                 13                    0.7458997
#>  ---                                                              
#> 125:     42.553328                  4                    0.6736657
#> 126:     50.007951                164                    1.0588572
#> 127:     50.005547                161                    1.2120772
#> 128:     42.865748                128                    0.9765346
#> 129:     45.134924                  1                    0.5444544
#>      NIR_CO_trev_1_num NIR_MD_hrv_classic_pnn40
#>                  <num>                    <num>
#>   1:       0.029297693                0.5826087
#>   2:      -0.018612421                0.5217391
#>   3:      -0.751222239                0.8000000
#>   4:       1.200472070                0.8565217
#>   5:       0.024270760                0.4695652
#>  ---                                           
#> 125:       0.027756341                0.6521739
#> 126:       0.009860880                0.3608696
#> 127:       0.009078954                0.2869565
#> 128:       0.053411233                0.5217391
#> 129:      -0.042982742                0.7043478
#>      NIR_SB_BinaryStats_mean_longstretch1
#>                                     <num>
#>   1:                                  133
#>   2:                                  134
#>   3:                                   88
#>   4:                                   85
#>   5:                                  138
#>  ---                                     
#> 125:                                  117
#> 126:                                  117
#> 127:                                  117
#> 128:                                  128
#> 129:                                  103
#>      NIR_SB_TransitionMatrix_3ac_sumdiagcov NIR_PD_PeriodicityWang_th0_01
#>                                       <num>                         <num>
#>   1:                             0.06250000                             5
#>   2:                             0.16666667                            10
#>   3:                             0.07407407                             3
#>   4:                             0.06250000                             4
#>   5:                             0.16666667                             6
#>  ---                                                                     
#> 125:                             0.16666667                             4
#> 126:                             0.16666667                             0
#> 127:                             0.16666667                             0
#> 128:                             0.07407407                             0
#> 129:                             0.11111111                             8
#>      NIR_CO_Embed2_Dist_tau_d_expfit_meandiff
#>                                         <num>
#>   1:                               0.42884280
#>   2:                               0.40813635
#>   3:                               0.03526442
#>   4:                               0.06976777
#>   5:                               0.55334737
#>  ---                                         
#> 125:                               0.33277897
#> 126:                               0.76350789
#> 127:                               0.69434863
#> 128:                               0.37350400
#> 129:                               0.19036719
#>      NIR_IN_AutoMutualInfoStats_40_gaussian_fmmi
#>                                            <num>
#>   1:                                           1
#>   2:                                           3
#>   3:                                           2
#>   4:                                           3
#>   5:                                           4
#>  ---                                            
#> 125:                                           1
#> 126:                                           2
#> 127:                                           4
#> 128:                                           1
#> 129:                                           4
#>      NIR_FC_LocalSimple_mean1_tauresrat NIR_DN_OutlierInclude_p_001_mdrmd
#>                                   <num>                             <num>
#>   1:                         0.01923077                        0.06493506
#>   2:                         0.01234568                        0.57142857
#>   3:                         0.01470588                       -0.61904762
#>   4:                         0.02127660                        0.20346320
#>   5:                         0.01204819                        0.59740260
#>  ---                                                                     
#> 125:                         0.01176471                        0.63636364
#> 126:                         0.01162791                        0.74025974
#> 127:                         0.01162791                        0.74458874
#> 128:                         0.01449275                        0.34199134
#> 129:                         0.01315789                       -0.70562771
#>      NIR_DN_OutlierInclude_n_001_mdrmd NIR_SP_Summaries_welch_rect_area_5_1
#>                                  <num>                                <num>
#>   1:                        -0.8181818                            0.8985138
#>   2:                        -0.8701299                            0.9509898
#>   3:                         0.6103896                            0.5333623
#>   4:                        -0.9047619                            0.4864089
#>   5:                        -0.8528139                            0.9132662
#>  ---                                                                       
#> 125:                        -0.8441558                            0.8764749
#> 126:                        -0.8008658                            0.9583462
#> 127:                        -0.7619048                            0.9594831
#> 128:                        -0.8441558                            0.9497204
#> 129:                         0.7424242                            0.8161740
#>      NIR_SB_BinaryStats_diff_longstretch0 NIR_SB_MotifThree_quantile_hh
#>                                     <num>                         <num>
#>   1:                                   29                      1.315276
#>   2:                                    4                      1.394753
#>   3:                                    8                      1.828160
#>   4:                                    6                      2.010899
#>   5:                                    4                      1.185274
#>  ---                                                                   
#> 125:                                    5                      1.373250
#> 126:                                    4                      1.185274
#> 127:                                    4                      1.185274
#> 128:                                   10                      1.338366
#> 129:                                    5                      1.681533
#>      NIR_SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
#>                                                <num>
#>   1:                                       0.4883721
#>   2:                                       0.3023256
#>   3:                                       0.5348837
#>   4:                                       0.5813953
#>   5:                                       0.5813953
#>  ---                                                
#> 125:                                       0.6744186
#> 126:                                       0.4418605
#> 127:                                       0.4418605
#> 128:                                       0.2558140
#> 129:                                       0.4418605
#>      NIR_SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
#>                                           <num>
#>   1:                                  0.8604651
#>   2:                                  0.3488372
#>   3:                                  0.8139535
#>   4:                                  0.1860465
#>   5:                                  0.1395349
#>  ---                                           
#> 125:                                  0.4186047
#> 126:                                  0.3953488
#> 127:                                  0.1395349
#> 128:                                  0.7674419
#> 129:                                  0.7674419
#>      NIR_SP_Summaries_welch_rect_centroid NIR_FC_LocalSimple_mean3_stderr
#>                                     <num>                           <num>
#>   1:                           0.02454369                       0.2574234
#>   2:                           0.02454369                       0.2316203
#>   3:                           0.39269908                       0.8196781
#>   4:                           0.61359232                       0.7764270
#>   5:                           0.02454369                       0.2193613
#>  ---                                                                     
#> 125:                           0.02454369                       0.4340053
#> 126:                           0.02454369                       0.1365554
#> 127:                           0.02454369                       0.1197464
#> 128:                           0.02454369                       0.2470460
#> 129:                           0.02454369                       0.5195790
#>      UVVIS_DN_HistogramMode_5 UVVIS_DN_HistogramMode_10 UVVIS_CO_f1ecac
#>                         <num>                     <num>           <num>
#>   1:              -0.76548678                -0.9871648       28.544177
#>   2:              -0.12166515                -0.3494136       28.338698
#>   3:              -0.34608226                -0.1002904       19.841067
#>   4:               0.05213751                -0.5373281       21.263534
#>   5:              -0.20955514                -0.4947158       25.893403
#>  ---                                                                   
#> 125:              -0.02941803                -0.3306574        2.835635
#> 126:              -0.93299051                -0.6707779       11.860308
#> 127:              -0.91466333                -1.1307723       19.247700
#> 128:              -1.09097234                -1.2774379       20.569486
#> 129:               0.58989186                 0.9084871       27.669540
#>      UVVIS_CO_FirstMin_ac UVVIS_CO_HistogramAMI_even_2_5 UVVIS_CO_trev_1_num
#>                     <num>                          <num>               <num>
#>   1:                    2                      0.8127115         0.005250231
#>   2:                    5                      0.6000956        -0.182501427
#>   3:                    1                      0.4424466        -0.169553664
#>   4:                    1                      0.3072650        -0.481512206
#>   5:                    1                      0.4781087        -0.053878703
#>  ---                                                                        
#> 125:                    2                      0.1493133         0.081184787
#> 126:                    1                      0.3779441         0.110193043
#> 127:                    1                      0.5517971        -0.046863292
#> 128:                   51                      0.7275115        -0.096419953
#> 129:                    3                      0.4685611        -0.963771103
#>      UVVIS_MD_hrv_classic_pnn40 UVVIS_SB_BinaryStats_mean_longstretch1
#>                           <num>                                  <num>
#>   1:                  0.7819549                                     53
#>   2:                  0.8345865                                     59
#>   3:                  0.8571429                                     57
#>   4:                  0.9022556                                     47
#>   5:                  0.8571429                                     52
#>  ---                                                                  
#> 125:                  0.9097744                                     29
#> 126:                  0.9022556                                     26
#> 127:                  0.8796992                                     18
#> 128:                  0.8646617                                     40
#> 129:                  0.8721805                                     62
#>      UVVIS_SB_TransitionMatrix_3ac_sumdiagcov UVVIS_PD_PeriodicityWang_th0_01
#>                                         <num>                           <num>
#>   1:                               0.16666667                               2
#>   2:                               0.16666667                               5
#>   3:                               0.07407407                               4
#>   4:                               0.07407407                               4
#>   5:                               0.11111111                               4
#>  ---                                                                         
#> 125:                               0.11111111                               5
#> 126:                               0.04166667                               3
#> 127:                               0.06250000                               5
#> 128:                               0.06250000                               5
#> 129:                               0.16666667                               4
#>      UVVIS_CO_Embed2_Dist_tau_d_expfit_meandiff
#>                                           <num>
#>   1:                                 0.47392492
#>   2:                                 0.19688323
#>   3:                                 0.13097509
#>   4:                                 0.09064423
#>   5:                                 0.14354603
#>  ---                                           
#> 125:                                 0.06411008
#> 126:                                 0.11065767
#> 127:                                 0.19322124
#> 128:                                 0.24498558
#> 129:                                 0.11421431
#>      UVVIS_IN_AutoMutualInfoStats_40_gaussian_fmmi
#>                                              <num>
#>   1:                                             1
#>   2:                                             2
#>   3:                                             2
#>   4:                                             3
#>   5:                                             3
#>  ---                                              
#> 125:                                             1
#> 126:                                             2
#> 127:                                             4
#> 128:                                             4
#> 129:                                             2
#>      UVVIS_FC_LocalSimple_mean1_tauresrat UVVIS_DN_OutlierInclude_p_001_mdrmd
#>                                     <num>                               <num>
#>   1:                           0.02222222                          0.80970149
#>   2:                           0.02173913                          0.76492537
#>   3:                           0.02272727                          0.65671642
#>   4:                           0.02564103                          0.76119403
#>   5:                           0.02272727                          0.75373134
#>  ---                                                                         
#> 125:                           0.02439024                          0.77611940
#> 126:                           0.03448276                         -0.01492537
#> 127:                           0.03333333                          0.58955224
#> 128:                           0.03333333                          0.81343284
#> 129:                           0.02173913                          0.71641791
#>      UVVIS_DN_OutlierInclude_n_001_mdrmd UVVIS_SP_Summaries_welch_rect_area_5_1
#>                                    <num>                                  <num>
#>   1:                         -0.43656716                              0.9217206
#>   2:                         -0.59701493                              0.8562983
#>   3:                         -0.62686567                              0.7654664
#>   4:                         -0.53731343                              0.6951190
#>   5:                         -0.64179104                              0.7898758
#>  ---                                                                           
#> 125:                         -0.68656716                              0.5117292
#> 126:                         -0.20149254                              0.6871688
#> 127:                         -0.10447761                              0.8267342
#> 128:                         -0.08955224                              0.8857187
#> 129:                         -0.64179104                              0.7335173
#>      UVVIS_SB_BinaryStats_diff_longstretch0 UVVIS_SB_MotifThree_quantile_hh
#>                                       <num>                           <num>
#>   1:                                      4                        1.565376
#>   2:                                      4                        1.582308
#>   3:                                      5                        1.914436
#>   4:                                      6                        1.878493
#>   5:                                      4                        1.574847
#>  ---                                                                       
#> 125:                                      5                        1.888721
#> 126:                                      4                        1.926484
#> 127:                                      4                        1.756310
#> 128:                                      7                        1.618036
#> 129:                                      4                        1.607980
#>      UVVIS_SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
#>                                                  <num>
#>   1:                                         0.3589744
#>   2:                                         0.5128205
#>   3:                                         0.8461538
#>   4:                                         0.5128205
#>   5:                                         0.3076923
#>  ---                                                  
#> 125:                                         0.8461538
#> 126:                                         0.6153846
#> 127:                                         0.5128205
#> 128:                                         0.6666667
#> 129:                                         0.8205128
#>      UVVIS_SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
#>                                             <num>
#>   1:                                    0.6666667
#>   2:                                    0.6666667
#>   3:                                    0.6666667
#>   4:                                    0.8461538
#>   5:                                    0.6666667
#>  ---                                             
#> 125:                                    0.8205128
#> 126:                                    0.4358974
#> 127:                                    0.6410256
#> 128:                                    0.5384615
#> 129:                                    0.5897436
#>      UVVIS_SP_Summaries_welch_rect_centroid UVVIS_FC_LocalSimple_mean3_stderr
#>                                       <num>                             <num>
#>   1:                             0.04908739                         0.2896300
#>   2:                             0.04908739                         0.4476950
#>   3:                             0.04908739                         0.6284882
#>   4:                             0.04908739                         0.6596766
#>   5:                             0.04908739                         0.4611458
#>  ---                                                                         
#> 125:                             0.46633016                         0.8954584
#> 126:                             0.07363108                         0.6667376
#> 127:                             0.04908739                         0.4409287
#> 128:                             0.04908739                         0.4126393
#> 129:                             0.04908739                         0.5796865
```
