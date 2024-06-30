#' @title Scale Functional Data
#' @name mlr_pipeops_fda.scale
#'
#' @description
#' Needs to be done
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' po_scale = po("fda.scale")
#' task_scale = po_scale$train(list(task))[[1L]]
#' task_scale
PipeOpFDAScale = R6Class("PipeOpFDAScale",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.scale"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.scale", param_vals = list()) {
      param_set = ps()

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf"),
        feature_types = "tfd_reg",
        tags = "fda"
      )
    }
  ),
  private = list(
    .transform_dt = function(dt, levels) {
      map_dtc(dt, function(x) {
        arg = tf::tf_arg(x)
        domain = tf::tf_domain(x)
        arg = (arg - domain[1L]) / (domain[2L] - domain[1L])
        invoke(tf::tfd, data = tf::tf_evaluations(x), arg = arg)
      })
    }
  )
)

scale_min_max = function(x) {
  lower = min(x)
  upper = max(x)
  (x - lower) / (upper - lower)
}

#' @include zzz.R
register_po("fda.scale", PipeOpFDAScale)
