# B-spline Feature Extraction

This `PipeOp` extracts features from functional data using B-spline
basis functions. The extracted features are B-spline coefficients that
represent the functional data in the B-spline basis space. For more
details, see
[`FDboost::bsignal()`](https://rdrr.io/pkg/FDboost/man/bsignal.html),
which is called internally.

## Parameters

The parameters are the parameters inherited from
[`PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html),
as well as the following parameters:

- `inS` :: `character(1)`  
  Type of effect in the covariate index: one of `"smooth"`, `"linear"`,
  `"constant"`. Default `"smooth"`.

- `knots` :: [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  Either the number of interior knots or a vector of their positions.

- `boundary.knots` :: `numeric(2)`  
  Boundary points at which to anchor the B-spline basis. Lower and upper
  boundary points for the spline basis. Defaults to the range of the
  data.

- `degree` :: `integer(1)`  
  The degree of the regression spline. Default is `3L`.

- `differences` :: `integer(1)`  
  Order of difference penalty. Default is `1L`.

- `df` :: `numeric(1)`  
  Trace of the hat matrix, controlling smoothness. Default is `4`.

- `lambda` :: `any`  
  Smoothing parameter of the penalty term.

- `center` :: `logical(1)`  
  Reparameterize the unpenalized part to zero-mean? Default is `FALSE`.

- `cyclic` :: `logical(1)`  
  If true the fitted coefficient function coincides at the boundaries.

- `Z` :: `any`  
  Custom transformation matrix for the spline design.

- `penalty` :: `character(1)`  
  The penalty type: `"ps"` (P-spline) or `"pss"` (shrinkage). Default is
  `"ps"`.

- `check.ident` :: `logical(1)`  
  Use checks for identifiability of the effect. Default is `FALSE`.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFDABsignal`

## Methods

### Public methods

- [`PipeOpFDABsignal$new()`](#method-PipeOpFDABsignal-new)

- [`PipeOpFDABsignal$clone()`](#method-PipeOpFDABsignal-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFDABsignal$new(id = "fda.bsignal", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default is `"fda.bsignal"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFDABsignal$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("fuel")
po_bsignal = po("fda.bsignal")
task_bsignal = po_bsignal$train(list(task))[[1L]]
task_bsignal$data()
#>       heatan    h20  NIR_bsig_1 NIR_bsig_2   NIR_bsig_3  NIR_bsig_4  NIR_bsig_5
#>        <num>  <num>       <num>      <num>        <num>       <num>       <num>
#>   1: 26.7810 2.3000  0.30895622  3.8875914   8.25757958   9.8406292  10.8301760
#>   2: 27.4720 3.0000  0.23327867  2.6601669   5.63516646   7.0596187   7.9722599
#>   3: 23.8400 2.0002  0.00420622  0.1589861   0.46226576   0.6461524   0.6917787
#>   4: 18.1680 1.8500 -0.02755544 -0.1833916  -0.06140228   0.2132759   0.4183076
#>   5: 17.5170 2.3898 -0.10914767 -0.8979161  -0.87913829   0.1334393   0.9413606
#>  ---                                                                           
#> 125: 23.8340 2.1100 -0.01670794  0.1136370   0.74273390   1.3216435   1.8541903
#> 126: 11.8050 1.6200 -0.56152878 -5.9478765 -10.02857886  -9.1745939  -7.9582820
#> 127:  8.8315 1.4200 -0.71792538 -7.7929493 -13.40606760 -12.1496590 -10.6249247
#> 128: 11.3450 1.4800 -0.05080034 -0.4621451  -0.10831877   1.0637056   2.1666883
#> 129: 28.9940 2.5000  0.12943297  1.5660204   3.13869555   3.3369191   3.3178924
#>      NIR_bsig_6 NIR_bsig_7 NIR_bsig_8 NIR_bsig_9 NIR_bsig_10 NIR_bsig_11
#>           <num>      <num>      <num>      <num>       <num>       <num>
#>   1: 11.5088941 11.9779453 12.1174704 11.8896232 11.31273620  10.3142375
#>   2:  8.7009409  9.3186404  9.7793087 10.1117548 10.30913017  10.4431357
#>   3:  0.6619125  0.5616062  0.3914156  0.1792577 -0.05370359  -0.2567235
#>   4:  0.5895871  0.6671312  0.6518124  0.5860669  0.46229636   0.3720952
#>   5:  1.5466583  2.0786524  2.4936812  2.7882146  2.94989453   3.0272675
#>  ---                                                                    
#> 125:  2.2003123  2.4912186  2.7998685  3.1179365  3.40765873   3.6379200
#> 126: -6.7631558 -5.5856955 -4.4352248 -3.3389506 -2.30337614  -1.2999487
#> 127: -9.0919723 -7.6142066 -6.1450498 -4.7293855 -3.39252094  -2.1272856
#> 128:  3.1888364  4.0518420  4.7226769  5.0945124  5.05592522   4.5462792
#> 129:  3.2478410  3.0527724  2.8059147  2.4792764  2.11115502   1.7602283
#>      NIR_bsig_12 NIR_bsig_13   NIR_bsig_14 UVVIS_bsig_1 UVVIS_bsig_2
#>            <num>       <num>         <num>        <num>        <num>
#>   1:   8.6066847   3.9933853  0.3114637655    0.4585002     4.890468
#>   2:  10.1912504   5.4302742  0.4637101954   -0.5708314    -6.053981
#>   3:  -0.2807225  -0.0953887 -0.0004178588   -0.1310900    -1.802917
#>   4:   0.4691400   0.4674304  0.0680371347   -0.2848928    -3.032630
#>   5:   3.0416345   1.8975896  0.2049782592   -0.4715812    -5.115183
#>  ---                                                                
#> 125:   3.5969034   1.9189905  0.1661176880   -0.3497554    -3.722387
#> 126:  -0.2804047   0.5021154  0.1130349769   -0.5268493    -5.421564
#> 127:  -0.8090823   0.4545185  0.1383324083   -0.4829044    -5.405378
#> 128:   3.4893505   1.6835206  0.1703526458    0.3369005     3.698122
#> 129:   1.5024626   0.7557343  0.0642844968   -0.4782980    -5.062383
#>      UVVIS_bsig_3 UVVIS_bsig_4 UVVIS_bsig_5 UVVIS_bsig_6 UVVIS_bsig_7
#>             <num>        <num>        <num>        <num>        <num>
#>   1:     9.167148     9.672084     9.520349     9.498991     9.937508
#>   2:   -11.287193   -12.208947   -11.981817   -11.501893   -10.789400
#>   3:    -3.872221    -4.627530    -4.102450    -3.643340    -3.417431
#>   4:    -5.662221    -6.373050    -6.577991    -6.650986    -6.384284
#>   5:    -9.748116   -10.629157   -10.448650   -10.270920    -9.875425
#>  ---                                                                 
#> 125:    -6.699699    -7.113708    -7.247388    -7.355720    -7.292643
#> 126:    -9.953552   -11.201759   -12.193262   -12.507825   -12.440546
#> 127:   -10.712849   -12.383363   -13.638517   -14.476519   -14.740431
#> 128:     6.766475     6.744222     5.625725     4.769732     4.403105
#> 129:    -8.954765    -9.530065    -9.225618    -8.259241    -7.506374
#>      UVVIS_bsig_8 UVVIS_bsig_9 UVVIS_bsig_10 UVVIS_bsig_11 UVVIS_bsig_12
#>             <num>        <num>         <num>         <num>         <num>
#>   1:    10.999917    12.339975     13.586039     14.647183     15.086214
#>   2:    -9.819931    -8.794243     -7.763370     -6.892750     -5.887550
#>   3:    -3.067908    -2.649421     -2.298166     -2.229685     -2.168885
#>   4:    -5.963247    -5.467640     -4.858720     -4.333341     -3.707709
#>   5:    -9.268580    -8.357216     -7.413833     -6.783725     -6.242212
#>  ---                                                                    
#> 125:    -6.974161    -6.675450     -6.358119     -5.881807     -5.364075
#> 126:   -12.210762   -11.820169    -11.289500    -10.798583     -9.726063
#> 127:   -14.392768   -13.694971    -12.866094    -11.971076    -10.668189
#> 128:     4.745962     5.537319      6.473936      7.326784      7.793231
#> 129:    -6.790662    -6.016780     -5.296986     -4.987682     -4.529120
#>      UVVIS_bsig_13 UVVIS_bsig_14
#>              <num>         <num>
#>   1:      8.531411     0.7990913
#>   2:     -3.206092    -0.3343597
#>   3:     -1.300891    -0.1382287
#>   4:     -2.155522    -0.2086386
#>   5:     -3.087076    -0.2551800
#>  ---                            
#> 125:     -3.066321    -0.2856197
#> 126:     -5.054930    -0.4535036
#> 127:     -5.445452    -0.4886222
#> 128:      4.382803     0.4038778
#> 129:     -2.582181    -0.2778649
```
