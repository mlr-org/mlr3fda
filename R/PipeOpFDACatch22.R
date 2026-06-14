#' @title Catch22 Feature Extraction
#'
#' @name mlr_pipeops_fda.catch22
#'
#' @description
#' This `PipeOp` extracts the 22 (or 24) canonical time series characteristics (catch22) from functional columns.
#' For more details, see [Rcatch22::catch22_all()], which is called internally on each curve.
#'
#' The catch22 set is a low-redundancy subset of the \pkg{hctsa} features, selected for their performance across a
#' diverse collection of time series classification tasks, but applicable as general-purpose features for other tasks
#' such as regression.
#'
#' For other time series feature extractors, see [`PipeOpFDATsfeatures`].
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `catch24` :: `logical(1)`\cr
#'   If `TRUE`, additionally compute the mean and standard deviation (the catch24 set), yielding 24 features instead
#'   of 22. Default is `FALSE`.
#'
#' @section Naming:
#' The new names generally append a `_{feature}` to the corresponding column name.
#' If a column was called `"x"` and the feature is `"DN_HistogramMode_5"`, the corresponding new column will
#' be called `"x_DN_HistogramMode_5"`.
#'
#' @export
#' @examplesIf requireNamespace("Rcatch22", quietly = TRUE)
#' task = tsk("fuel")
#' po_catch22 = po("fda.catch22")
#' task_catch22 = po_catch22$train(list(task))[[1L]]
#' task_catch22$data()
PipeOpFDACatch22 = R6Class(
  "PipeOpFDACatch22",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.catch22"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.catch22", param_vals = list()) {
      param_set = ps(
        catch24 = p_lgl(default = FALSE, tags = c("train", "predict"))
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf", "Rcatch22"),
        feature_types = c("tfd_reg", "tfd_irreg"),
        tags = "fda"
      )
    }
  ),

  private = list(
    .transform_dt = function(dt, levels) {
      catch24 = self$param_set$get_values()$catch24 %??% FALSE

      setcbindlist(imap(dt, function(x, nm) {
        feats = map_dtr(tf::tf_evaluations(x), function(x) {
          # suppress Rcatch22's once-per-session notice about CO_f1ecac's return type
          res = suppressWarnings(invoke(Rcatch22::catch22_all, x, catch24 = catch24))
          set_names(as.list(res$values), res$names)
        })
        setnames(feats, sprintf("%s_%s", nm, names(feats)))
      }))
    }
  )
)

#' @include zzz.R
register_po("fda.catch22", PipeOpFDACatch22)
