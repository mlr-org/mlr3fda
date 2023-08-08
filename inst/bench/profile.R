library(profvis)
library(mlr3fda)
library(mlr3pipelines)


task = tsk("fuel")
po_fmean = po("ffs", feature = "mean", id = "mean", drop = FALSE)
po_fvar = po("ffs", feature = "var", id = "var", drop = FALSE)
po_fslope = po("ffs", feature = "slope", id = "slope", drop = FALSE)
graph = po_fmean %>>%
  po_fvar %>>%
  po_fslope

profvis({
  graph$train(task)
})
