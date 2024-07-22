#' @title Functional Principal Component Analysis
#' @name mlr_pipeops_fda.fpca
#'
#' @description
#' This `PipeOp` applies a functional principal component analysis (FPCA) to functional columns and then
#' extracts the principal components as features. This is done using a (truncated) weighted SVD.
#'
#' To apply this `PipeOp` to irregualr data, convert it to a regular grid first using [`PipeOpFDAInterpol`].
#'
#' For more details, see [tf::tfb_fpc()], which is called internally.
#'
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreproc`][mlr3pipelines::PipeOpTaskPreproc],
#' as well as the following parameters:
#' * `pve` :: `numeric(1)` \cr
#'   The percentage of variance explained that should be retained. Default is `0.995`.
#' * `n_components` :: `integer(1)` \cr
#'   The number of principal components to extract. This parameter is initialized to `Inf`.
#'
#' @section Naming:
#' The new names generally append a `_pc_{number}` to the corresponding column name.
#' If a column was called `"x"` and the there are three principcal components, the corresponding
#' new columns will be called `"x_pc_1", "x_pc_2", "x_pc_3"`.
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' po_fpca = po("fda.fpca", n_components = 3L)
#' task_fpca = po_fpca$train(list(task))[[1L]]
#' task_fpca$data()
PipeOpFPCA = R6Class("PipeOpFPCA",
  inherit = PipeOpTaskPreproc,
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
      pars = self$param_set$get_values(tags = "train")

      dt = map_dtc(dt, function(x, nm) {
        invoke(tf::tfb_fpc, data = x, .args = remove_named(pars, "n_components"))
      })
      self$state = list(fpc = dt)

      dt = imap_dtc(dt, function(col, nm) {
        map(col, function(x) {
          pc = as.list(x[2:min(pars$n_components + 1L, length(x))])
          set_names(pc, sprintf("%s_pc_%d", nm, seq_along(pc)))
        })
      })
      unnest(dt, names(dt))
    },

    .predict_dt = function(dt, levels) {
      pars = self$param_set$get_values()

      dt = imap_dtc(dt, function(col, nm) {
        fpc = invoke(
          tf::tf_rebase,
          object = col,
          basis_from = self$state$fpc[[nm]],
          arg = tf::tf_arg(col)
        )
        map(fpc, function(x) {
          pc = as.list(x[2:min(pars$n_components + 1L, length(x))])
          set_names(pc, sprintf("%s_pc_%d", nm, seq_along(pc)))
        })
      })
      unnest(dt, names(dt))
    }
  )
)

#' @include zzz.R
register_po("fda.fpca", PipeOpFPCA)
