# Changelog

## mlr3fda (development version)

- fix: The `fuel` task now correctly names the scalar column `h2o`
  instead of `h20`.
- feat: `Mlr3Error` and `Mlr3Warning` classes for errors and warnings.
- chore: mlr3fda now requires mlr3 (\>= 1.3.0) and mlr3misc (\>=
  0.19.0).
- chore: require `data.table` \>= 1.18.0.

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
