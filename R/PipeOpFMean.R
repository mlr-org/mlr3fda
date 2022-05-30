#' (F)unction Mean
#'
#' @usage NULL
#' @name mlr_pipeops_ffe
#' @format [`R6Class`] object inheriting from
#' [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]
#'
#' @description
#' One can think of this PipeOp as applying the rolling mean for a given window size - specified in
#' terms of area on the x-axis, not number of observations - and appending the last mean as a
#' feature to the Task
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
#'
#' @section Methods:
#' Only methods inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]/
#' [`PipeOp`][mlr3pipelines::PipeOp]
#'
#' @export
PipeOpFMean = R6Class("PipeOpFMean",
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(

    #' @description Initializes a new instance of this Class.
    #' @param id ()`character(1)`)\cr
    #'   Identifier of resulting object, default `"ffe"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    initialize = function(id = "ffe", param_vals = list()) {
      param_set = ps(
        drop = p_lgl(default = TRUE, tags = c("train", "predict")),
        window = p_uty(default = NULL, tags = c("train", "predict"), custom_check = check_window)
      )

      param_set$values$drop = TRUE

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
      drop = self$param_set$values$drop
      window = self$param_set$values$window

      one_window = is.numeric(window)

      if (is.list(window)) {
        assert_set_equal(cols, names(window))
      }

      feature_names = sprintf("%s.fmean", cols)
      feature_names = uniqueify(feature_names, task$col_info$id)

      features = list()

      for (i in seq_along(dt)) {
        nm = names(dt)[[i]]
        if (one_window) {
          x = fmean(dt[[nm]], window)
        } else {
          x = fmean(dt[[nm]], window[[nm]])
        }
        features[[feature_names[i]]] = x
      }

      features = as.data.table(features)
      if (!drop) {
        features = cbind(dt, features)
      }

      task$select(setdiff(task$feature_names, cols))$cbind(features)
      return(task)
    }
  )
)

fmean = function(x, window = NULL) {
  assert_numeric(window, len = 1L, min = 0, null.ok = TRUE)
  m = numeric(length(x))

  args_vec = tf::tf_arg(x)
  values_vec = map(unclass(x), "value")


  for (i in seq_along(x)) {
    args = args_vec[[i]]
    values = values_vec[[i]]

    if (is.null(window)) {
      m[i] = mean(values)
    } else  {
      # here it is assumed that there are no NAs (NA values are dropped when creating tfd)
      start_arg = args[length(args)] - window
      # we use Position to find the FIRST element, there is always one --> x:y is fine
      start_pos = Position(function(v) v >= start_arg, args)
      m[i] = mean(values[start_pos:length(values)])
    }
  }
  return(m)
}

check_window = function(x) {
  if (test_numeric(x, len = 1)) {
    return(TRUE)
  } else if (test_list(x, types = "numeric", any.missing = FALSE, min.len = 1, names = "named")) {
    return(TRUE)
  } else if (test_null(x)) {
    return(TRUE)
  }
  return("Window must be numeric, named list or NULL.")
}


