#' @title Interpolate Functional Columns
#' @name mlr_pipeops_fda.interpol
#'
#' @description
#' Interpolate functional features (e.g. all individuals are observed at different time-points) to a common grid.
#' This is useful if you want to compare functional features across observations.
#' The interpolation is done using the `tf` package. See [`tfd()`][tf::tfd] for details.
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
#'   The grid to use for interpolation.
#'   If `grid` is numeric, it must be a sequence of values to use for the grid or a single value that
#'   specifies the number of points to use for the grid, requires `left` and `right` to be specified.
#'   If `grid` is a character, it must be one of:
#'   * `"union"`: This option creates a grid based on the union of all argument points from the provided functional
#'     features. This means that if the argument points across features are \(t_1, t_2, ..., t_n\), then the grid will
#'     be the combined unique set of these points. This option is generally used when the argument points vary across
#'     observations and a  common grid is needed for comparison or further analysis.
#'   * `"intersect"`: The grid is created based on the intersection of all argument points of a feature.
#'   * `"minmax"`: This option constructs a grid that spans from the maximum of the minimum argument points to the
#'     minimum of the maximum argument points across the provided functional features. It creates a bounded grid that
#'     encapsulates the range within which all features have defined argument points.
#'   For regular functional data this has no effect.
#'   Initial value is `"union"`.
#' * `method` :: `character(1)` \cr
#'   Defaults to `"linear"`. One of:
#'   * `"linear"`: applies linear interpolation without extrapolation (see `tf::tf_approx_linear()`).
#'   * `"spline"`: applies cubic spline interpolation (see `tf::tf_approx_spline()`).
#'   * `"fill_extend"`: applies linear interpolation with constant extrapolation (see `tf::tf_approx_fill_extend()`).
#'   * `"locf"`: applies "last observation carried forward" interpolation (see `tf::tf_approx_locf()`).
#'   * `"nocb"`: applies "next observation carried backward" interpolation (see `tf::tf_approx_nocb()`).
#' * `left` :: `numeric()` \cr
#'   The left boundary of the window.
#'   The window is specified such that the all values >=left and <=right are kept for the computations.
#' * `right` :: `numeric()` \cr
#'   The right boundary of the window.
#'
#' @export
#' @examples
#' library(mlr3pipelines)
#' task = tsk("fuel")
#' pop = po("fda.interpol")
#' task_interpol = pop$train(list(task))
PipeOpFDAInterpol = R6Class("PipeOpFDAInterpol",
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.interpol"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.interpol", param_vals = list()) {
      param_set = ps(
        grid = p_uty(tags = c("train", "predict", "required"), custom_check = crate(function(x) {
          if (test_string(x)) {
            return(check_choice(x, choices = c("union", "intersect", "minmax")))
          }
          if (test_numeric(x, any.missing = FALSE, min.len = 1)) {
            return(TRUE)
          }
          "Must be either a string or numeric vector."
        })),
        method = p_fct(
          c("linear", "spline", "fill_extend", "locf", "nocb"), default = "linear", tags = c("train", "predict")
        ),
        left = p_dbl(tags = c("train", "predict")),
        right = p_dbl(tags = c("train", "predict"))
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
    .transform_dt = function(dt, levels) {
      pars = self$param_set$get_values()
      grid = pars$grid
      method = pars$method
      left = pars$left
      right = pars$right
      if (!is.null(left) && !is.null(right)) {
        assert_count(grid)
        assert_true(left <= right)
      }
      method = method %??% "linear"
      evaluator = sprintf("tf_approx_%s", method)
      map_dtc(dt, function(x) interpolate_col(x, grid, evaluator, left, right))
    }
  )
)

interpolate_col = function(x, grid, evaluator, left, right) {
  if (is.numeric(grid)) {
    if (length(grid) > 1L && is.null(left) && is.null(right)) {
      arg = unlist(tf::tf_arg(x))
      if (max(grid) > max(arg) || min(grid) < min(arg)) {
        stopf("The grid must be within the range of the argument points.")
      }
      arg = grid
    } else {
      arg = seq(left, right, length.out = grid)
    }
  } else if (tf::is_reg(x)) {
    return(x)
  } else {
    arg = tf::tf_arg(x)
    switch(grid,
      "union" = {
        arg = sort(unique(unlist(arg)))
      },
      "intersect" = {
        arg = Reduce(intersect, arg)
      },
      "minmax" = {
        lower = max(map_dbl(arg, 1L))
        upper = min(map_dbl(arg, function(arg) arg[[length(arg)]]))
        arg = sort(unique(unlist(arg)))
        arg = arg[which(lower == arg):which(upper == arg)]
      }
    )
  }
  invoke(tf::tfd, .args = list(data = x, arg = arg, evaluator = evaluator))
}

#' @include zzz.R
register_po("fda.interpol", PipeOpFDAInterpol)
