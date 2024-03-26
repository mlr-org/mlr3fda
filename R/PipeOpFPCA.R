#' @title Functional Principal Component Analysis
#' @name mlr_pipeops_fda.fpca
#'
#' @format [`R6Class`] object inheriting from
#' [`PipeOpTaskPreproc`][mlr3pipelines::PipeOpTaskPreproc]
#'
#' @description
#' This is the class that extracts principal components from functional columns.
#' See [`tfb_fpc()`][tf::tfb_fpc] for details.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreproc`], as well as the following parameters:
#' * `pve` :: `numeric(1)` \cr
#'   The percentage of variance explained that should be retained.
#' * `n_components` :: `integer(1)` \cr
#'   The number of principal components to extract.
#'
#' @section Naming:
#' The new names generally append a `_pc_{number}` to the corresponding column name.
#' If a column was called `"x"` and the there are three principcal components, the corresponding
#' new columns will be called `"x_pc_1", "x_pc_2", "x_pc_3"`.
#'
#' @section Internals:
#' Uses the [`tfb_fpc()`][tf::tfb_fpc] function.
#'
#' @section Methods:
#' Only methods inherited from [`PipeOpTaskPreproc`][mlr3pipelines::PipeOpTaskPreproc]/
#' [`PipeOp`][mlr3pipelines::PipeOp]
#'
#' @export
#' @examples
#' library(mlr3pipelines)
#'
#' task = tsk("fuel")
#' po_fpca = po("fda.fpca")
#' task_fpca = po_fpca$train(list(task))[[1L]]
PipeOpFPCA = R6Class("PipeOpFPCA",
  inherit = mlr3pipelines::PipeOpTaskPreproc,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default is `"fda.fpca"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.fpca", param_vals = list()) {
      param_set = ps(
        pve = p_dbl(default = 0.995, lower = 0, upper = 1, tags = "train"),
        n_components = p_int(1L, special_vals = list(Inf), tags = c("train", "required"))
      )
      param_set$set_values(n_components = Inf)

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
    .train_dt = function(dt, levels, target) {
      pars = self$param_set$get_values()

      dt = map_dtc(dt, function(x, nm) invoke(tf::tfb_fpc, data = x, .args = pars$pve))
      self$state = list(fpc = dt)

      dt = imap_dtc(dt, function(col, nm) {
        map(col, function(x) {
          pc = as.list(x[2:min(pars$n_components + 1L, length(x))])
          set_names(pc, sprintf("%s_pc_%d", nm, seq_along(pc)))
        })
      })
      unnest(dt, colnames(dt))
    },

    .predict_dt = function(dt, levels) {
      pars = self$param_set$get_values()

      dt = imap_dtc(dt, function(col, nm) {
        fpc = tf::tf_rebase(col, self$state$fpc[[nm]], arg = tf::tf_arg(col))
        map(fpc, function(x) {
          pc = as.list(x[2:min(pars$n_components + 1L, length(x))])
          set_names(pc, sprintf("%s_pc_%d", nm, seq_along(pc)))
        })
      })
      unnest(dt, colnames(dt))
    }
  )
)

#' @include zzz.R
register_po("fda.fpca", PipeOpFPCA)
