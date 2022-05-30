#' @import mlr3
#' @import checkmate
#' @import mlr3misc
#' @import paradox
#' @import mlr3misc
#' @import R6
#' @import data.table
#' @import mlr3pipelines
#'
#'
#' @description
#' Extends mlr3 with the functional data type.
#' `r tools::toRd(citation("mlr3"))`
"_PACKAGE"


register_mlr3 = function() {
  mlr_reflections = utils::getFromNamespace("mlr_reflections", ns = "mlr3")
  mlr_pipeops = utils::getFromNamespace("mlr_pipeops", ns = "mlr3pipelines")
  mlr_pipeops$add("fmean", PipeOpFMean)
  mlr_task = utils::getFromNamespace("mlr_tasks", ns = "mlr3")
  mlr_tasks$add("fuel", load_task_fuel)
  mlr_tasks$add("phoneme", load_task_phoneme)
  mlr_reflections$task_feature_types[["fun"]] = "tfd_irreg"
  mlr_pipeops$add("flatfunct", PipeOpFlatFunct)
  mlr_pipeops$add("ffe", PipeOpFFE)
}


.onLoad = function(libname, pkgname) {
  mlr3misc::register_namespace_callback(pkgname, "mlr3", register_mlr3)
}
