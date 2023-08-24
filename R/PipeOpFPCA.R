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
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default is `"fpca"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fpca", param_vals = list()) {
      param_set = ps(
        drop = p_lgl(tags = c("train", "predict", "required")),
        pve = p_dbl(default = 0.995, lower = 0, upper = 1, tags = c("train", "predict")),
        n_components = p_int(1L, special_vals = list(Inf), tags = c("train", "predict", "required"))
      )

      param_set$set_values(
        drop = FALSE,
        n_components = Inf
      )

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
    .transform = function(task) {
      cols = self$state$dt_columns
      if (!length(cols)) {
        return(task)
      }
      dt = task$data(cols = cols)
      pars = self$param_set$get_values()
      drop = pars$drop
      n_components = pars$n_components
      args = pars["pve"]

      features = map(cols, function(col) {
        feature = invoke(tf::tfb_fpc, data = dt[[col]], .args = args)
        feature = map(feature, function(x) x[2:min(n_components + 1L, length(x))])
        feature = transform_list(feature)
        nms = sprintf("%s_pc_%d", col, seq_along(feature))
        feature = set_names(feature, nms)
      })
      features = unlist(features, recursive = FALSE)

      feature_names = names(features)
      if (anyDuplicated(c(task$col_info$id, feature_names))) {
        warningf("Unique names for features were created due to name clashes with existing columns.")
        feature_names = make.unique(c(task$col_info$id, feature_names), sep = "_")
        feature_names = feature_names[(length(task$col_info$id) + 1L):length(feature_names)]
        features = set_names(features, feature_names)
      }

      features = as.data.table(features)

      if (!drop) {
        features = cbind(dt, features)
      }

      task$select(setdiff(task$feature_names, cols))$cbind(features)
      task
    }
  )
)

#' @include zzz.R
register_po("fpca", PipeOpFPCA)
