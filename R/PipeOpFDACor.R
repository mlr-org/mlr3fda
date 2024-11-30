#' @title Cross-Correlation of Functional Data
#' @name mlr_pipeops_fda.cor
#'
#' @description
#' Calculates the cross-correlation between two functional vectors using [tf::tf_crosscor()].
#' Note that it only operates on regular data and that the cross-correlation assumes that each column
#' has the same domain.
#'
#' To apply this `PipeOp` to irregualr data, convert it to a regular grid first using [`PipeOpFDAInterpol`].
#' If you need to change the domain of the columns, use [`PipeOpFDAScaleRange`].
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `arg` :: `numeric()`\cr
#'   Grid to use for the cross-correlation.
#'
#' @export
#' @examples
#' set.seed(1234L)
#' dt = data.table(y = 1:100, x1 = tf::tf_rgp(100L), x2 = tf::tf_rgp(100L))
#' task = as_task_regr(dt, target = "y")
#' po_cor = po("fda.cor")
#' task_cor = po_cor$train(list(task))[[1L]]
#' task_cor
PipeOpFDACor = R6Class("PipeOpFDACor",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.cor"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.cor", param_vals = list()) {
      param_set = ps(
        arg = p_uty(tags = c("train", "predict"), custom_check = check_numeric)
      )

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
      pars = self$param_set$get_values()

      k = ncol(dt)
      if (k < 2L) {
        warningf("task has less than 2 columns")
        return(dt)
      }

      nms = names(dt)
      res = list()
      for (i in 2:k) {
        for (j in 1:(i - 1L)) {
          x = dt[[i]]
          y = dt[[j]]
          if (!all(tf::tf_domain(x) == tf::tf_domain(y))) {
            stopf("Domain of %s and %s do not match", nms[[j]], nms[[i]])
          }
          nm = sprintf("%s_%s_cor", nms[[j]], nms[[i]])
          res[[nm]] = invoke(tf::tf_crosscor, x = x, y = y, .args = pars)
        }
      }
      setDT(res)
    }
  )
)

#' @include zzz.R
register_po("fda.cor", PipeOpFDACor)
