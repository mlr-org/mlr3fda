#' @title Smoothing Functional Columns
#' @name mlr_pipeops_fda.cor
#'
#' @description
#' Smoothes functional data using [`tf::tf_smooth()`].
#' This preprocessing operator is similar to [`PipeOpFDAInterpol`], however it does not interpolate to unobserved
#' x-values, but rather smooths the observed values.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`], as well as the following
#' parameters:
#' * `grid` :: `numeric()` \cr
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
#' library(mlr3pipelines)
#'
#' task = tsk("dti")
#' po_cor = po("fda.cor")
#' task_cor = po_cor$train(list(task))[[1L]]
#' task_cor
#' task_cor$data(cols = c("NIR", "UVVIS"))
PipeOpFDACor = R6Class("PipeOpFDACor",
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.cor"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.cor", param_vals = list()) {
      param_set = ps()

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
      arg = pars$args

      nms = names(dt)
      res = list()
      for (i in 2:ncol(dt)) {
        for (j in 1:(i - 1)) {
          x = dt[[i]]
          y = dt[[j]]
          x = invoke(tf::tfd, data = x, arg = arg)
          y = invoke(tf::tfd, data = y, arg = arg)
          nm = sprintf("%s_%s_cor", nms[[i]], nms[[j]])
          res[[nm]] = invoke(tf::tf_crosscor, x = x, y = y, arg = arg)
        }
      }
      setDT(res)
    }
  )
)

#' @include zzz.R
register_po("fda.cor", PipeOpFDACor)
