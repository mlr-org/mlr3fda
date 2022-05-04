#' @import mlr3
#' @import checkmate
#' @import mlr3misc
#' @import paradox
#' @import mlr3misc
#' @import R6
#' @import data.table
#'
#' @description
#' Extends mlr3 with the functional data type.
#' `r tools::toRd(citation("mlr3"))`
"_PACKAGE"


register_mlr3 = function() {
  mlr_reflections = utils::getFromNamespace("mlr_reflections", ns = "mlr3")

  mlr_reflections$task_feature_types[["fun"]] = "functional"
}


.onLoad = function(libname, pkgname) {
  mlr3misc::register_namespace_callback(pkgname, "mlr3", register_mlr3)
}
