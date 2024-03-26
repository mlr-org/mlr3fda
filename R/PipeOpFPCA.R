#' (F)unctional (P)rincipal (C)ommponent (A)nalysis
#'
#' @usage NULL
#' @name mlr_pipeops_fpca
#' @format [`R6Class`] object inheriting from
#' [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]
#'
#' @description
#' This is the class that extracts principal components from functional columns.
#' Note that it only operates on values that were actually observed and does not interpolate.
#'
#' @section Parameters:
#' * `drop` :: `logical(1)`\cr
#'   Whether to drop the original `functional` features and only keep the extracted features.
#'   Note that this does not remove the features from the backend, but only from the active
#'   column role `feature`. Initial is `FALSE`.
#' * `affect_columns` :: `function` | [`Selector`] | `NULL` \cr
#'   What columns the [`PipeOpTaskPreproc`] should operate on.
#'   See [`Selector`] for example functions. Defaults to `NULL`, which selects all features.
#'
#' @section Naming:
#' The new names generally append a `_fpca_{number}` to the corresponding column name.
#' However this can lead to name clashes with existing columns. This is solved as follows:
#' If a column was called `"x"` and the there are three principcal components, the corresponding
#' new columns will be called `"x_pc_1", "x_pc_2", "x_pc_3"`.
#' In case of duplicates, unique names are obtained using `make.unique()` and a warning is given.
#'
#' @section Methods:
#' Only methods inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]/
#' [`PipeOp`][mlr3pipelines::PipeOp]
#'
#' @export
#' @examples
#' library(mlr3pipelines)
#' task = tsk("fuel")
#' po_fpca = po("fpca")
#' task_fpca = po_fpca$train(list(task))[[1L]]
PipeOpFPCA = R6Class("PipeOpFPCA",
  inherit = mlr3pipelines::PipeOpTaskPreproc,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default is `"fpca"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fpca", param_vals = list()) {
      param_set = ps(
        pve = p_dbl(default = 0.995, lower = 0, upper = 1, tags = "train"),
        n_components = p_int(1L, special_vals = list(Inf), tags = c("train", "required"))
      )
      param_set$set_values(n_components = Inf)

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines"),
        feature_types = "tfd_reg"
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
          pcr = as.list(x[2:min(pars$n_components + 1L, length(x))])
          set_names(pcr, sprintf("%s_pc_%d", nm, seq_along(pcr)))
        })
      })
      unnest(dt, colnames(dt))
    },

    .predict_dt = function(dt, levels) {
      pars = self$param_set$get_values()

      dt = imap_dtc(dt, function(col, nm) {
        fpc = tf::tf_rebase(col, self$state$fpc[[nm]], arg = tf::tf_arg(col))
        map(fpc, function(x) {
          pcr = as.list(x[2:min(pars$n_components + 1L, length(x))])
          set_names(pcr, sprintf("%s_pc_%d", nm, seq_along(pcr)))
        })
      })
      unnest(dt, colnames(dt))
    }
  )
)

#' @include zzz.R
register_po("fpca", PipeOpFPCA)
