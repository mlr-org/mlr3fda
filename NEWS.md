# mlr3fda (development version)

* feat: `Mlr3Error` and `Mlr3Warning` classes for errors and warnings.
* chore: mlr3cluster now requires mlr3 (>= 1.3.0) and mlr3misc (>= 0.19.0).
* chore: require `data.table` >= 1.18.0.

# mlr3fda 0.3.0

* mlr3fda now depends on R 4.1.0 instead of R 3.1.0 to reflect tf requiring 4.1.0
* New PipeOps:
  * `PipeOpFDABsignal`
  * `PipeOpFDARandomEffect`
  * `PipeOpFDATsfeatures`
  * `PipeOpFDAWavelets`
  * `PipeOpFDAZoom`

# mlr3fda 0.2.0

* New PipeOps:
  * `PipeOpFDACor`
  * `PipeOpFDAScaleRange`
* mlr3fda now depends on mlr3pipelines

# mlr3fda 0.1.1

* Fix CRAN issues

# mlr3fda 0.1.0

Initial CRAN release.
