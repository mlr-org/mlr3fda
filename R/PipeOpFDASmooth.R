#' @title Smoothing Functional Columns
#' @name mlr_pipeops_fda.smooth
#'
#' @description
#' Smoothes functional data using [tf::tf_smooth()].
#' This preprocessing operator is similar to [`PipeOpFDAInterpol`], however it does not interpolate to unobserved
#' x-values, but rather smooths the observed values.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `method` :: `character(1)`\cr
#'   One of:
#'   * `"lowess"`: locally weighted scatterplot smoothing (default)
#'   * `"rollmean"`: rolling mean
#'   * `"rollmedian"`: rolling meadian
#'   * `"savgol"`:  Savitzky-Golay filtering
#'
#'   All methods but "lowess" ignore non-equidistant arg values.
#' * `args` :: named `list()`\cr
#'   List of named arguments that is passed to `tf_smooth()`. See the help page of `tf_smooth()` for
#'   default values.
#' * `verbose` :: `logical(1)`\cr
#'   Whether to print messages during the transformation.
#'   Is initialized to `FALSE`.
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' po_smooth = po("fda.smooth", method = "rollmean", args = list(k = 5))
#' task_smooth = po_smooth$train(list(task))[[1L]]
#' task_smooth
#' task_smooth$data(cols = c("NIR", "UVVIS"))
PipeOpFDASmooth = R6Class("PipeOpFDASmooth",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.smooth"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.smooth", param_vals = list()) {
      param_set = ps(
        method = p_fct(default = "lowess", c("lowess", "rollmean", "rollmedian", "savgol"), tags = c("train", "predict")), # nolint
        args = p_uty(
          tags = c("train", "predict", "required"), custom_check = crate(function(x) check_list(x, names = "unique"))
        ),
        verbose = p_lgl(tags = c("train", "predict", "required"))
      )

      param_set$set_values(args = list(), verbose = FALSE)

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf", "stats"),
        feature_types = c("tfd_reg", "tfd_irreg"),
        tags = "fda"
      )
    }
  ),
  private = list(
    .transform_dt = function(dt, levels) {
      pars = self$param_set$get_values()

      if (pars$verbose) {
        map_dtc(dt, function(x) {
          invoke(tf::tf_smooth, x = x, method = pars$method, .args = pars$args)
        })
      } else {
        map_dtc(dt, function(x) {
          suppressMessages(invoke(tf::tf_smooth, x = x, method = pars$method, .args = pars$args))
        })
      }

    }
  )
)
#' @include zzz.R
register_po("fda.smooth", PipeOpFDASmooth)
