#' @title Interpolate Functional Columns
#' @name mlr_pipeops_fda.interpol
#'
#' @description
#' Interpolate functional features (e.g. all individuals are observed at different time-points) to a common grid.
#' This is useful if you want to compare functional features across observations.
#' The interpolation is done using the `tf` package. See [`tfd()`][tf::tfd] for details.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `grid` :: `character(1)` | `numeric()`\cr
#'   The grid to use for interpolation.
#'   If `grid` is numeric, it must be a sequence of values to use for the grid or a single value that
#'   specifies the number of points to use for the grid, requires `left` and `right` to be specified in the latter case.
#'   If `grid` is a character, it must be one of:
#'   * `"union"`: This option creates a grid based on the union of all argument points from the provided functional
#'     features. This means that if the argument points across features are \(t_1, t_2, ..., t_n\), then the grid will
#'     be the combined unique set of these points. This option is generally used when the argument points vary across
#'     observations and a  common grid is needed for comparison or further analysis.
#'   * `"intersect"`: Creates a grid using the intersection of all argument points of a feature.
#'     This grid includes only those points that are common across all functional features,
#'     facilitating direct comparison on a shared set of points.
#'   * `"minmax"`: Generates a grid within the range of the maximum of the minimum argument points to the minimum of the
#'     maximum argument points across features.
#'     This bounded grid encapsulates the argument point range common to all features.
#'   Note: For regular functional data this has no effect as all argument points are the same.
#'   Initial value is `"union"`.
#' * `method` :: `character(1)`\cr
#'   Defaults to `"linear"`. One of:
#'   * `"linear"`: applies linear interpolation without extrapolation (see [tf::tf_approx_linear()]).
#'   * `"spline"`: applies cubic spline interpolation (see [tf::tf_approx_spline()]).
#'   * `"fill_extend"`: applies linear interpolation with constant extrapolation (see [tf::tf_approx_fill_extend()]).
#'   * `"locf"`: applies "last observation carried forward" interpolation (see [tf::tf_approx_locf()]).
#'   * `"nocb"`: applies "next observation carried backward" interpolation (see [tf::tf_approx_nocb()]).
#' * `left` :: `numeric()`\cr
#'   The left boundary of the window.
#'   The window is specified such that the all values >=left and <=right are kept for the computations.
#' * `right` :: `numeric()`\cr
#'   The right boundary of the window.
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' pop = po("fda.interpol")
#' task_interpol = pop$train(list(task))[[1L]]
#' task_interpol$data()
PipeOpFDAInterpol = R6Class("PipeOpFDAInterpol",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.interpol"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.interpol", param_vals = list()) {
      param_set = ps(
        grid = p_uty(tags = c("train", "predict", "required"), custom_check = crate(function(x) {
          if (test_string(x)) {
            return(check_choice(x, choices = c("union", "intersect", "minmax")))
          }
          if (test_numeric(x, any.missing = FALSE, min.len = 1L)) {
            return(TRUE)
          }
          "Must be either a string or numeric vector"
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
        packages = c("mlr3fda", "mlr3pipelines", "tf"),
        feature_types = c("tfd_reg", "tfd_irreg"),
        tags = "fda"
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
      has_left = !is.null(left)
      has_right = !is.null(right)
      if (xor(has_left, has_right)) {
        stopf("Either both or none of 'left' and 'right' must be specified.")
      }
      if (has_left && has_right) {
        assert_count(grid)
        assert_true(left <= right)
      }
      method = method %??% "linear"
      evaluator = sprintf("tf_approx_%s", method)

      if (is.numeric(grid)) {
        if (length(grid) > 1L && !has_left && !has_right) {
          max_grid = max(grid)
          min_grid = min(grid)
          for (j in seq_along(dt)) {
            x = dt[[j]]
            domain = tf::tf_domain(x)
            if (min_grid < domain[[1L]] || max_grid > domain[[2L]]) {
              stopf("The grid must be within the range of the domain.")
            }
            set(dt, j = j, value = invoke(tf::tfd, data = x, arg = grid, .args = list(evaluator = evaluator)))
          }
          return(dt)
        }
        arg = seq(left, right, length.out = grid)
        for (j in seq_along(dt)) {
          set(dt, j = j, value = invoke(tf::tfd, data = dt[[j]], arg = arg, .args = list(evaluator = evaluator)))
        }
        return(dt)
      }

      for (j in seq_along(dt)) {
        x = dt[[j]]
        if (tf::is_irreg(x)) {
          arg = tf::tf_arg(x)
          arg = switch(
            grid,
            union = sort(unique(unlist(arg, recursive = FALSE, use.names = FALSE))),
            intersect = Reduce(intersect, arg),
            minmax = {
              lower = max(map_dbl(arg, 1L))
              upper = min(map_dbl(arg, function(arg) arg[[length(arg)]]))
              arg = sort(unique(unlist(arg, recursive = FALSE, use.names = FALSE)))
              arg[seq(which(lower == arg), which(upper == arg))]
            }
          )
          set(dt, j = j, value = invoke(tf::tfd, data = x, arg = arg, .args = list(evaluator = evaluator)))
        }
      }
      dt
    }
  )
)

#' @include zzz.R
register_po("fda.interpol", PipeOpFDAInterpol)
