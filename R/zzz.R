#' @import mlr3
#' @import checkmate
#' @import mlr3misc
#' @import paradox
#' @import mlr3misc
#' @import R6
#' @import data.table
#' @import mlr3pipelines
#' @importFrom tf tf_approx_linear tf_approx_spline tf_approx_fill_extend tf_approx_locf tf_approx_nocb
#'
#' @section Data types:
#' To extend mlr3 to functional data, two data types from the tf package are added:
#' * `tfd_irreg` - Irregular functional data, i.e. the functions are observed for
#'   potentiall different inputs for each observation.
#' * `tfd_reg` - Regular functional data, i.e. the functions are observed for the same input
#'   for each individual.
#'
#' `r tools::toRd(citation("mlr3"))`
"_PACKAGE"


# metainf must be manually added in the register_mlr3pipelines function
# Because the value is substituted, we cannot pass it through this function
register_po = function(name, constructor) {
  if (name %in% names(mlr3fda_pipeops)) stopf("pipeop %s registered twice", name)
  mlr3fda_pipeops[[name]] = list(constructor = constructor)
}

register_task = function(name, constructor) {
  if (name %in% names(mlr3fda_tasks)) stopf("task %s registered twice", name)
  mlr3fda_tasks[[name]] = constructor
}

named_union = function(x, y) {
  z = union(x, y)
  set_names(z, union(names(x), names(y)))
}

mlr3fda_feature_types = c(tfr = "tfd_reg", tfi = "tfd_irreg")
mlr3fda_tasks = new.env()
mlr3fda_pipeops = new.env()
mlr3fda_pipeop_tags = "fda"

register_mlr3 = function() {
  # add data types
  mlr_reflections = utils::getFromNamespace("mlr_reflections", ns = "mlr3")
  mlr_reflections$task_feature_types = named_union(mlr_reflections$task_feature_types, mlr3fda_feature_types)

  # add tasks
  mlr_tasks = utils::getFromNamespace("mlr_tasks", ns = "mlr3")
  iwalk(as.list(mlr3fda_tasks), function(task, id) {
    mlr_tasks$add(id, task)
  })

}

register_mlr3pipelines = function() {
  mlr_reflections = utils::getFromNamespace("mlr_reflections", ns = "mlr3")
  mlr_pipeops = utils::getFromNamespace("mlr_pipeops", ns = "mlr3pipelines")
  iwalk(as.list(mlr3fda_pipeops), function(value, name) {
    mlr_pipeops$add(name, value$constructor, value$metainf)
  })
  mlr_reflections$pipeops$valid_tags = unique(c(mlr_reflections$pipeops$valid_tags, mlr3fda_pipeop_tags))
}

.onLoad = function(libname, pkgname) {
  assign("lg", lgr::get_logger("mlr3"), envir = parent.env(environment()))
  if (Sys.getenv("IN_PKGDOWN") == "true") {
    lg$set_threshold("warn")
  }
  mlr3misc::register_namespace_callback(pkgname, "mlr3", register_mlr3)
  mlr3misc::register_namespace_callback(pkgname, "mlr3pipelines", register_mlr3pipelines)
}

.onUnload = function(libPaths) { # nolint
  walk(names(mlr3fda_tasks), function(nm) mlr_tasks$remove(nm))
  walk(names(mlr3fda_pipeops), function(nm) mlr_pipeops$remove(nm))
  mlr_reflections$learner_feature_types = setdiff(mlr_reflections$learner_feature_types, mlr3fda_feature_types)
  mlr_reflections$pipeops$valid_tags = setdiff(mlr_reflections$pipeops$valid_tags, mlr3fda_pipeop_tags)
}

leanify_package()
