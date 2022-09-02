#' @import mlr3
#' @import checkmate
#' @import mlr3misc
#' @import paradox
#' @import mlr3misc
#' @import R6
#' @import data.table
#' @import mlr3pipelines
#'
#' @section Data types:
#' To extend mlr3 to functional data, two data types from the {tf} package are added:
#' * `tfd_irreg` - Irregular functional data, i.e. the functions are observed for
#'   potentiall different inputs for each observation.
#' * `tfd_reg` - Regular functional data, i.e. the functions are observed for the same input
#'   for each individual.
#'
#' `r tools::toRd(citation("mlr3"))`
"_PACKAGE"


register_mlr3 = function() {
  # add data types
  mlr_reflections = utils::getFromNamespace("mlr_reflections", ns = "mlr3")
  mlr_reflections$task_feature_types[["f_irreg"]] = "tfd_irreg"
  mlr_reflections$task_feature_types[["f_reg"]] = "tfd_reg"

  # add tasks
  mlr_task = utils::getFromNamespace("mlr_tasks", ns = "mlr3")
  mlr_tasks$add("fuel", load_task_fuel)
  mlr_tasks$add("phoneme", load_task_phoneme)

  # add pipeops
  mlr_pipeops$add("flatfun", PipeOpFlatFun)
  mlr_pipeops = utils::getFromNamespace("mlr_pipeops", ns = "mlr3pipelines")
  mlr_pipeops$add("ffs", PipeOpFFS)
}


.onLoad = function(libname, pkgname) {
  mlr3misc::register_namespace_callback(pkgname, "mlr3", register_mlr3)
}
