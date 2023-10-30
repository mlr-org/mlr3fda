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
#' * `grid` :: `character(1)` | numeric() \cr
#'   The grid to use for interpolation. If `grid` is a character, it must be either `"union"` or `"intersect"`.
#'   If `grid` is numeric, it must be a sequence of values to use for the grid.
#'   Default is `"union"`.
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
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"flatfun"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "flatfun", param_vals = list()) {
      param_set = ps(
        grid = p_uty(tags = c("train", "predict", "required"), custom_check = crate(function(x) {
          if (test_string(x)) {
            return(check_choice(x, choices = c("union", "intersect")))
          }
          if (test_numeric(x)) {
            return(TRUE)
          }
          "Must be either a character or numeric vector."
        }))
      )
      param_set$set_values(grid = "union")

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines"),
        feature_types = c("tfd_reg", "tfd_irreg")
      )
    }
  ),
  private = list(
    .transform = function(task) {
      cols = self$state$dt_columns
      if (!length(cols)) {
        return(task)
      }
      pars = self$param_set$get_values()
      grid = pars$grid

      dt = task$data(cols = cols)

      flattened = imap(
        dt,
        function(x, nm) {
          if (!is.character(grid)) {
            flat = as.matrix(x, arg = grid, interpolate = TRUE)
          } else if (grid == "union") {
            flat = as.matrix(x, interpolate = TRUE)
          } else {
            args = tf::tf_arg(x)
            lower = max(map_dbl(args, 1))
            upper = min(map_dbl(args, function(arg) arg[[length(arg)]]))
            args = sort(unique(unlist(args)))
            grid = args[which(lower == args):which(upper == args)]
            browser()
            flat = as.matrix(x, arg = grid, interpolate = TRUE)
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
        warningf("Unique names for features were created due to name clashes with existing columns.")
        feature_names = make.unique(c(task$col_info$id, feature_names), sep = "_")
        feature_names = feature_names[(length(task$col_info$id) + 1L):length(feature_names)]
      }
      colnames(dt_flat) = feature_names

      task$select(setdiff(task$feature_names, cols))$cbind(dt_flat)
    }
  )
)

#' @include zzz.R
register_po("flatfun", PipeOpFlatFun)
