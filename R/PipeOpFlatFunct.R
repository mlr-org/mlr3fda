#' @title Flattens Functional Columns
#'
#' @name mlr_pipeops_flatfunct
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`], as well as the following
#' parameters:
#' * `as_features` :: `logical()`\cr
#'   Whether to add the Flattened values to the features of the task.
#' * `selector` :: `function` | [`Selector`][mlr3pipelines::Selector] \cr
#'   [`Selector`][mlr3pipelines::Selector] function, takes a `Task` as argument and returns a `character`
#'   of features to keep. The flattening is only applied to those columns.\cr
#'   See [`Selector`][mlr3pipelines::Selector] for example functions. Default is
#'   selector_all()`, which selects all of the `functional` features.
#'
#' @export
PipeOpFlatFunct = R6Class("PipeOpFlatFunct",
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id ()`character(1)`)\cr
    #'   Identifier of resulting object, default `"ffe"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "flatfunct", param_vals = list()) {
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
        feature_types = "functional"
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

      # TODO: check that there are no name clashes

      # TODO: to be save we should write the .transform function (and not transform_dt), because
      # we cannot ensure that we don't have name-clashes with the original data.table
      flattened = imap(dt,
        function(x, nm) {
          flat = flatten_functional(x)
          d = as.data.table(flat)
          d
        }
      )
      # convert to data.table and append names
      dt_flat = invoke(cbind, .args = flattened)

      task$select(setdiff(task$feature_names, cols))$cbind(dt_flat)
    }
  )
)

