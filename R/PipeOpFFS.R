#' (F)unctional (F)eature (S)imple
#'
#' @usage NULL
#' @name mlr_pipeops_ffs
#' @format [`R6Class`] object inheriting from
#' [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]
#'
#' @description
#' This is the class that extracts simple features from functional columns.
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
#' * `features` :: `list()` \cr
#'   A list of features to extract. Each element can be either a function or a string.
#'   If the element if is function it requires the following arguments: `arg` and `value` and returns a `numeric`.
#'   For string elements, the following predefined features are available:
#'   `"mean"`, `"max"`,`"min"`,`"slope"`,`"median"`,`"var"`.
#'   The features that are extracted.
#' * `left` :: `numeric()` \cr
#'   The left boundary of the window. Initial is `-Inf`.
#'   The window is specified such that the all values >=left and <=right are kept for the computations.
#' * `right` :: `numeric()` \cr
#'   The right boundary of the window. Initial is `Inf`.
#'
#' @section Naming:
#' The new names generally append a `_{feature}` to the corresponding column name.
#' However this can lead to name clashes with existing columns.
#' This is solved as follows:
#' If a column was called `"x"` and the feature is `"mean"`, the corresponding new column will
#' be called `"x_mean"`. In case of duplicates, unique names are obtained using `make.unique()` and
#' a warning is given.
#'
#' @section Methods:
#' Only methods inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]/
#' [`PipeOp`][mlr3pipelines::PipeOp]
#'
#' @export
#' @examples
#' library(mlr3pipelines)
#' task = tsk("fuel")
#' pop = po("ffs", feature = "mean")
#' task_fmean = pop$train(list(task))[[1L]]
PipeOpFFS = R6Class("PipeOpFFS",
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default is `"ffs"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    initialize = function(id = "ffs", param_vals = list()) {
      param_set = ps(
        drop = p_lgl(tags = c("train", "predict", "required")),
        left = p_dbl(tags = c("train", "predict", "required")),
        right = p_dbl(tags = c("train", "predict", "required")),
        features = p_uty(tags = c("train", "predict", "required"))
      )
      param_set$set_values(
        drop = FALSE,
        left = -Inf,
        right = Inf
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines"),
        feature_types = c("tfd_irreg", "tfd_reg")
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
      features = pars$features
      left = pars$left
      right = pars$right
      assert_true(left <= right)
      assert_list(features, types = c("character", "function"), any.missing = FALSE, unique = TRUE)
      walk(features, function(feature) {
        if (is.function(feature)) {
          assert_function(feature, args = c("arg", "value"))
        } else {
          assert_choice(feature, choices = c("mean", "median", "min", "max", "slope", "var"))
        }
      })

      # handle name clashes of generated features with existing columns
      feature_names = imap_chr(features, function(value, nm) {
        if (is.function(value)) nm else value
      })
      feature_names = as.vector(t(outer(cols, feature_names, paste, sep = "_")))

      if (anyDuplicated(c(task$col_info$id, feature_names))) {
        warningf("Unique names for features were created due to name clashes with existing columns.")
        feature_names = make.unique(c(task$col_info$id, feature_names), sep = "_")
        feature_names = feature_names[(length(task$col_info$id) + 1L):length(feature_names)]
      }

      features = map(features, function(feature) {
        if (is.function(feature)) {
          return(feature)
        }
        switch(feature,
          mean = fmean,
          median = fmedian,
          min = fmin,
          max = fmax,
          slope = fslope,
          var = fvar
        )
      })
      fextractor = make_fextractor(features)

      features = map(
        cols,
        function(col) {
          x = dt[[col]]
          invoke(fextractor, x = x, left = left, right = right)
        }
      )

      features = unlist(features, recursive = FALSE)
      features = set_names(features, feature_names)
      features = as.data.table(features)

      if (!drop) {
        features = cbind(dt, features)
      }

      task$select(setdiff(task$feature_names, cols))$cbind(features)
      task
    }
  )
)

make_fextractor = function(features) {
  function(x, left = -Inf, right = Inf) {
    args = tf::tf_arg(x)

    if (tf::is_reg(x)) {
      interval = ffind(args, left = left, right = right)
      lower = interval[[1L]]
      upper = interval[[2L]]

      if (is.na(lower) || is.na(upper)) {
        res = map(features, function(f) {
          rep(NA_real_, length(x)) # no observation in the given interval [left, right]
        })
        return(res)
      }

      res = map(seq_along(x), function(i) {
        value = tf::tf_evaluations(x[i])[[1L]]
        map(features, function(f) {
          f(arg = args[lower:upper], value = value[lower:upper])
        })
      })
      res = transpose_list(res)
      res = map(res, unlist)
      return(res)
    }

    res = map(seq_along(x), function(i) {
      arg = args[[i]]
      value = tf::tf_evaluations(x[i])[[1L]]

      interval = ffind(arg, left = left, right = right)
      lower = interval[[1L]]
      upper = interval[[2L]]

      if (is.na(lower) || is.na(upper)) {
        rep(NA_real_, length(features)) # no observation in the given interval [left, right]
      } else {
        map(features, function(f) {
          f(arg = arg[lower:upper], value = value[lower:upper])
        })
      }
    })
    res = transpose_list(res)
    map(res, unlist)
  }
}

ffind = function(x, left = -Inf, right = Inf) {
  len = length(x)
  if (left <= x[[1L]] && right >= x[[len]]) {
    return(c(1L, len))
  }
  if (left > x[[len]] || right < x[[1L]]) {
    return(rep(NA_integer_, 2L))
  }
  it = findInterval(c(left, right), x)
  if (it[[1L]] == 0L) {
    it[[1L]] = 1L
  } else if (x[[it[[1L]]]] < left) {
    it[[1L]] = it[[1L]] + 1L
  }
  it
}

fmean = function(arg, value) mean(value, na.rm = TRUE)
fmin = function(arg, value) min(value, na.rm = TRUE)
fmax = function(arg, value) max(value, na.rm = TRUE)
fmedian = function(arg, value) median(value, na.rm = TRUE)
fslope = function(arg, value) coefficients(lm(value ~ arg))[[2L]]
fvar = function(arg, value) var(value, na.rm = TRUE)

#' @include zzz.R
register_po("ffs", PipeOpFFS)
