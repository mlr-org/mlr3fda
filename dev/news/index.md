# Changelog

## mlr3fda (development version)

- fix: `as.data.table(mlr_pipeops)` no longer errors with
  `object 'value' not found` when `mlr3fda` is loaded.
- feat: New `PipeOpFDACatch22` for extracting the catch22 time series
  features from functional columns via
  [`Rcatch22::catch22_all()`](https://rdrr.io/pkg/Rcatch22/man/catch22_all.html).
- feat: New `PipeOpFDAIntegrate` for extracting the definite integral of
  functional columns via
  [`tf::tf_integrate()`](https://tidyfun.github.io/tf/reference/tf_integrate.html).

## mlr3fda 0.6.0

CRAN release: 2026-06-01

- fix: Add `mlr3fda` to `mlr_reflections$loaded_packages` to fix errors
  when using `mlr3fda` in parallel.
- feat: New `PipeOpFDADepth` for computing the data depth of functional
  columns via
  [`tf::tf_depth()`](https://tidyfun.github.io/tf/reference/tf_depth.html).
- feat: New `PipeOpFDADerive` for computing derivatives of functional
  columns via
  [`tf::tf_derive()`](https://tidyfun.github.io/tf/reference/tf_derive.html).
- feat: `PipeOpFDAExtract` gained the `"sd"` feature for extracting the
  standard deviation.
- perf: `PipeOpFDAFourier` is now several times faster.

## mlr3fda 0.5.0

CRAN release: 2026-05-03

- feat: New `PipeOpFDARegister` for aligning functional columns to a
  learned template via
  [`tf::tf_register()`](https://tidyfun.github.io/tf/reference/tf_register.html).

## mlr3fda 0.4.0

CRAN release: 2026-03-30

- fix: The `fuel` task now correctly names the scalar column `h2o`
  instead of `h20`.
- feat: `Mlr3Error` and `Mlr3Warning` classes for errors and warnings.
- feat: New `PipeOpFDAFourier` for extracting fast Fourier transform
  features from functional columns.

## mlr3fda 0.3.0

CRAN release: 2025-10-15

- mlr3fda now depends on R 4.1.0 instead of R 3.1.0 to reflect tf
  requiring 4.1.0
- New PipeOps:
  - `PipeOpFDABsignal`
  - `PipeOpFDARandomEffect`
  - `PipeOpFDATsfeatures`
  - `PipeOpFDAWavelets`
  - `PipeOpFDAZoom`

## mlr3fda 0.2.0

CRAN release: 2024-07-22

- New PipeOps:
  - `PipeOpFDACor`
  - `PipeOpFDAScaleRange`
- mlr3fda now depends on mlr3pipelines

## mlr3fda 0.1.1

CRAN release: 2024-04-09

- Fix CRAN issues

## mlr3fda 0.1.0

CRAN release: 2024-04-04

Initial CRAN release.
