#' @title Cross-Correlation of Functional Data
#' @name mlr_pipeops_fda.cor
#'
#' @description
#' Calculates the cross-correlation between two functional vectors using [tf::tf_crosscor()].
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`], as well as the following
#' parameters:
#' * `grid` :: `numeric()` \cr
#'
#' @export
#' @examples
#' library(mlr3pipelines)
#'
#' task = tsk("fuel")
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
        feature_types = "tfd_reg",
        tags = "fda"
      )
    }
  ),
  private = list(
    .transform_dt = function(dt, levels) {
      pars = self$param_set$get_values()

      nms = names(dt)
      res = list()
      for (i in 2:ncol(dt)) {
        for (j in 1:(i - 1)) {
          x = dt[[i]]
          y = dt[[j]]
          domain_x = tf::tf_domain(x)
          domain_y = tf::tf_domain(y)

          if (!all(domain_x == domain_y)) {
            lower = max(domain_x[[1L]], domain_y[[1L]])
            upper = min(domain_x[[2L]], domain_y[[2L]])
            args_x = tf::tf_arg(x)
            interval_x = ffind(args_x, left = lower, right = upper)
            args_x = args_x[interval_x[[1L]]:interval_x[[2L]]]
            x = invoke(tf::tfd, data = x, arg = args_x)
            args_y = tf::tf_arg(y)
            interval_y = ffind(args_y, left = lower, right = upper)
            args_y = args_y[interval_y[[1L]]:interval_y[[2L]]]
            y = invoke(tf::tfd, data = y, arg = args_y)
          }

          nm = sprintf("%s_%s_cor", nms[[i]], nms[[j]])
          res[[nm]] = invoke(tf::tf_crosscor, x = x, y = y)
        }
      }
      setDT(res)
    }
  )
)

#' @include zzz.R
register_po("fda.cor", PipeOpFDACor)
