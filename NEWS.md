# mlr3fda (development version)

# mlr3fda 0.7.0

* fix: `PipeOpFDAWavelets` no longer errors when `filter` is a `wt.filter` object or a numeric vector. Generated columns are now named `<column>_wav_<i>` regardless of the filter.
* fix: `PipeOpFDAZoom` now accepts a one-sided `begin` or `end` instead of requiring both.
* fix: `as.data.table(mlr_pipeops)` no longer errors with `object 'value' not found` when `mlr3fda` is loaded.
* feat: New `PipeOpFDACatch22` for extracting the catch22 time series features from functional columns via `Rcatch22::catch22_all()`.
* feat: New `PipeOpFDAIntegrate` for extracting the definite integral of functional columns via `tf::tf_integrate()`.

# mlr3fda 0.6.0

* fix: Add `mlr3fda` to `mlr_reflections$loaded_packages` to fix errors when using `mlr3fda` in parallel.
* feat: New `PipeOpFDADepth` for computing the data depth of functional columns via `tf::tf_depth()`.
* feat: New `PipeOpFDADerive` for computing derivatives of functional columns via `tf::tf_derive()`.
* feat: `PipeOpFDAExtract` gained the `"sd"` feature for extracting the standard deviation.
* perf: `PipeOpFDAFourier` is now several times faster.

# mlr3fda 0.5.0

* feat: New `PipeOpFDARegister` for aligning functional columns to a learned template via `tf::tf_register()`.

# mlr3fda 0.4.0

* fix: The `fuel` task now correctly names the scalar column `h2o` instead of `h20`.
* feat: `Mlr3Error` and `Mlr3Warning` classes for errors and warnings.
* feat: New `PipeOpFDAFourier` for extracting fast Fourier transform features from functional columns.

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
