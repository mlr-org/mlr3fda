#' (F)unctional (F)eature (S)imple
#'
#' @usage NULL
#' @name mlr_pipeops_ffs
#' @format [`R6Class`] object inheriting from
#' [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]
#'
#' @description
#' This is the class that extracts simple features from functional columns.
#'
#' @section Parameters:
#' * `drop` :: `logical(1)`\cr
#'   Whether to drop the original `functional` features and only keep the extracted features.
#'   Note that this does not remove the features from the backend, but only from the active
#'   column role `feature`.
#' * `affect_columns` :: `function` | [`Selector`] | `NULL` \cr
#'   What columns the [`PipeOpTaskPreproc`] should operate on. This parameter
#'   is only present if the constructor is called with the `can_subset_cols`
#'   argument set to `TRUE` (the default).\cr The parameter must be a
#'   [`Selector`] function, which takes a [`Task`][mlr3::Task] as argument and
#'   returns a `character`
#'   of features to use.\cr
#'   See [`Selector`] for example functions. Defaults to `NULL`, which selects all features.
#' * `window` :: `integer()` | named `list()` | `NULL \cr
#'   The window size. When passing a named list, different window sizes can be specified for each
#'   feature by using it's name. If left `NULL`, the window size is set to Inf.
#'   The window specifies the d such that all values within $[x - w, x]$ are used to compute the
#'   simple feature. Here $x$ is the rightmost (or leftmost, if `left == TRUE`) argument for
#'   which the function was observed.
#' * `feature` :: `charater()` \cr
#'   One of `"mean"`, `"max"`,`"min"`,`"slope"`,`"median"`.
#'   The feature that is extracted.
#'
#' @section Methods:
#' Only methods inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]/
#' [`PipeOp`][mlr3pipelines::PipeOp]
#'
#' @export
PipeOpFFS = R6Class("PipeOpFFS",
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id ()`character(1)`)\cr
    #'   Identifier of resulting object, default `"ffe"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    initialize = function(id = "ffe", param_vals = list()) {
      param_set = ps(
        drop = p_lgl(default = FALSE, tags = c("train", "predict")),
        window = p_uty(tags = c("train", "predict"), custom_check = check_window),
        feature = p_fct(
          levels = c("mean", "max", "min", "slope", "median"),
          tags = c("train", "predict", "required")
        ),
        left = p_lgl(default = FALSE, tags = c("train", "predict"))
      )
      param_set$values = list(
        left = FALSE,
        drop = FALSE,
        window = Inf
      )

      super$initialize(
        id = id,
        param_set = param_set,
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
      # TODO: to be save we should write the .transform function (and not transform_dt), because
      # we cannot ensure that we don't have name-clashes with the original data.table
      # This is also a FIXME in mlr3pipelines
      pars = self$param_set$values
      drop = pars$drop
      feature = pars$feature
      left = pars$left
      window = pars$window

      feature_names = uniqueify(sprintf("%s.f%s", cols, feature), task$col_info$id)

      one_window = length(window) == 1L

      fextractor = switch(feature,
        mean = fmean,
        median = fmedian,
        min = fmin,
        max = fmax,
        slope = fslope
      )

      features = map(
        cols,
        function(col) {
          if (one_window) {
            window_col = window
          } else {
            window_col = window[[col]]
          }
          x = dt[[col]]
          invoke(fextractor, x = x, window = window_col, left = left)
        }
      )

      features = set_names(features, feature_names)

      features = as.data.table(features)

      if (!drop) {
        features = cbind(dt, features)
      }

      task$select(setdiff(task$feature_names, cols))$cbind(features)
      return(task)
    }
  )
)

make_fextractor = function(f) {
  function(x, window = Inf, left = FALSE) {
    assert_numeric(window, len = 1L, min = 0, null.ok = TRUE)
    m = numeric(length(x))

    args_vec = tf::tf_arg(x)
    values_vec = map(unclass(x), "value")

    for (i in seq_along(x)) {
      args = args_vec[[i]]
      values = values_vec[[i]]

      if (is.infinite(window)) {
        m[i] = mean(values)
      } else {
        # here it is assumed that there are no NAs (NA values are dropped when creating tfd)
        # Here it holds that:
        # * Position always finds an element
        # * There are no NA values (otherwise length(args) is not necessarily the upper and 1 not
        # necessarily the lower arg)
        if (left) {
          lower = 1
          upper_max = args[1L] + window
          upper = Position(function(v) v <= upper_max, args, right = left)
        } else {
          lower_min = args[length(args)] - window
          lower = Position(function(v) v >= lower_min, args, right = left)
          upper = length(args)
        }
        m[i] = f(values[lower:upper])
      }
    }
    return(m)
  }
}

fmean = make_fextractor(mean)
fmax = make_fextractor(max)
fmin = make_fextractor(min)
fmedian = make_fextractor(median)
fslope = make_fextractor(function(x) coefficients(lm(arg ~ value, x))["(Intercept)"])

check_window = function(x) {
  if (test_numeric(x, len = 1, lower = 0, null.ok = FALSE)) {
    return(TRUE)
  } else if (test_numeric(x, min.len = 1L, any.missing = FALSE, names = "named", lower = 0)) {
    return(TRUE)
  } else {
    return("Window must be numeric, named list or NULL.")
  }
}
