#' @title Flattens Functional Columns
#' @name mlr_pipeops_fda.flatten
#'
#' @description
#' Convert regular functional features (e.g. all individuals are observed at the same time-points)
#' to new columns, one for each input value to the function.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`].
#'
#' @section Naming:
#' The new names generally append a `_1`, ...,  to the corresponding column name.
#' However this can lead to name clashes with existing columns.
#' This is solved as follows:
#' If a column was called `"x"` and the feature is `"mean"`, the corresponding new column will
#' be called `"x_mean"`. In case of duplicates, unique names are obtained using `make.unique()` and
#' a warning is given.
#'
#' @export
#' @examples
#' library(mlr3pipelines)
#'
#' task = tsk("fuel")
#' pop = po("fda.flatten")
#' task_flat = pop$train(list(task))
PipeOpFDAFlatten = R6Class("PipeOpFDAFlatten",
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.flatten"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.flatten", param_vals = list()) {
      param_set = ps()

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf"),
        feature_types = c("tfd_reg", "tfd_irreg"),
        tags = "fda"
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

      flattened = imap(
        dt,
        function(x, nm) {
          if (tf::is_irreg(x)) {
            flat = suppressWarnings(as.matrix(x))
          } else {
            flat = as.matrix(x)
          }
          d = as.data.table(flat)
          setnames(d, sprintf("%s_%s", nm, seq_len(ncol(flat))))
        }
      )
      names(flattened) = NULL # this does not set the data.table names to NULL but the list names
      # convert to data.table and append names
      dt_flat = invoke(cbind, .args = flattened)
      feature_names = names(dt_flat)

      if (anyDuplicated(c(task$col_info$id, feature_names))) {
        unique_names = make.unique(c(task$col_info$id, feature_names), sep = "_")
        feature_names = tail(unique_names, length(feature_names))
        lg$debug(sprintf("Duplicate names found in pipeop %s", self$id), feature_names = feature_names)
      }
      colnames(dt_flat) = feature_names

      task$select(setdiff(task$feature_names, cols))$cbind(dt_flat)
    }
  )
)

#' @include zzz.R
register_po("fda.flatten", PipeOpFDAFlatten)
