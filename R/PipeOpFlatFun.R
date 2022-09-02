#' @title Flattens Functional Columns
#' @name mlr_pipeops_flatfun
#'
#' @description
#' Convert regular functional features (e.g. all individuals are observed at the same time-points)
#' to new columns, one for each input value to the function.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`], as well as the following
#' parameters:
#' * `affect_columns` :: `function` | [`Selector`][mlr3pipelines::Selector] \cr
#'   [`Selector`][mlr3pipelines::Selector] function, takes a `Task` as argument and returns a `character`
#'   of features to keep. The flattening is only applied to those columns.\cr
#'   See [`Selector`][mlr3pipelines::Selector] for example functions. Default is
#'   selector_all()`, which selects all of the `functional` features.
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
#' task = tsk("fuel")
#' pop = po("flatfun")
#' task_flat = pop$train(list(task))
PipeOpFlatFun = R6Class("PipeOpFlatFun",
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id ()`character(1)`)\cr
    #'   Identifier of resulting object, default `"ffe"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "flatfun", param_vals = list()) {
      param_set = ps()

      input = data.table(name = "input", train = "Task", predict = "Task")
      output = data.table(name = "output", train = "Task", predict = "Task")

      super$initialize(
        id = id,
        param_set = ps(),
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines"),
        feature_types = c("tfd_reg")
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
          flat = as.matrix(x)
          d = as.data.table(flat)
          d = set_names(d, sprintf("%s_%s", nm, seq(ncol(flat))))
          d
        }
      )
      names(flattened) = NULL # this does not set the data.table names to NULL but the list names
      # convert to data.table and append names
      dt_flat = invoke(cbind, .args = flattened)
      feature_names = names(dt_flat)

      if (anyDuplicated(c(task$col_info$id, feature_names))) {
        warningf("Unique names for features were created due to name clashes with existing columns.")
        feature_names = make.unique(c(task$col_info$id, feature_names), sep = "_")
        feature_names = feature_names[(length(task$col_info$id) + 1L):length(feature_names)]
      }
      colnames(dt_flat) = feature_names

      task$select(setdiff(task$feature_names, cols))$cbind(dt_flat)
    }
  )
)
