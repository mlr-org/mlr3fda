#' @title Flattens Functional Columns
#'
#' @name mlr_pipeops_flatfun
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
#' @export
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

      input = data.table(
        name = "input", train = "Task", predict = "Task"
      )
      output = data.table(
        name = "output", train = "Task", predict = "Task"
      )
      super$initialize(
        id = id,
        param_set = ps(),
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines"),
        feature_types = "tfd_irreg"
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
      unique_names = uniqueify(colnames(dt_flat), task$col_info$id)
      set_names(dt_flat, unique_names)

      task$select(setdiff(task$feature_names, cols))$cbind(dt_flat)
    }
  )
)
