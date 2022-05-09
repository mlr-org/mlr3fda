#' @title (F)unctional (F)eature (E)xtractor
#' @usage NULL
#' @name mlr_pipeops_ffe
#' @format [`R6Class`] object inheriting from
#' [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]
#'
#' @section Parameters
#' * `extractors` :: `list(x1 = fn1, x2 = fn2, ...)`\cr
#'   Named list of functions, that extract the features. The names are the suffixes that are
#'   appended to the original column names, and the values are the feature extractors and must
#'   return a list with values (i.e. the features). If there is more than one features, the
#'   corresponding number is additionally suffixed to the name of the extracted feature.
#' * `drop` :: `logical(1)`\cr
#'   Whether to drop the original `functional` features and only keep the extracted features.
#'   Note that this does not remove the features from the backend, but only from the active
#'   column role `feature`.
#'
#' @section Internals:
#' Applies `flatten_functional()`, converts to a data.table and appends it to the features of
#' the task.
#'
#' @section Methods:
#' Only methods inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]/
#' [`PipeOp`][mlr3pipelines::PipeOp]
#'
#' @export
PipeOpFFE = R6Class("PipeOpFFE",
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(
    initialize = function(id = "ffe", param_vals = list()) {
      param_set = ps(
        extractors = p_uty(tags = c("train", "predict", "required")),
        drop = p_lgl(default = TRUE, tags = c("train"))
      )
      param_set$values$drop = TRUE

      super$initialize(
        id = id,
        param_set = param_set,
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
      # TODO: to be save we should write the .transform function (and not transform_dt), because
      # we cannot ensure that we don't have name-clashes with the original data.table
      # This is also a FIXME in mlr3pipelines
      drop = self$param_set$values$drop
      extractors = self$param_set$values$extractors

      # create feature names and then create the unique values
      feature_names = map(cols,
        function(x) {
          map_chr(names(extractors),
            function(y) {
              sprintf("%s.%s", x, y)
            }
          )
        }
      )
      # unlist because the case where we calculate only 1 feature returns a list of length 1,
      # wich does

      # there are edge cases, namely when we have 1 feature or one column
      # that we have to deal with,

      feature_names = simplify2array(feature_names)
      if (length(cols) == 1L)  {
        feature_names = matrix(feature_names, ncol = 1L)
      }
      if (length(extractors) == 1) {
        feature_names = matrix(feature_names, nrow = 1L)
      }
      if (length(feature_names) == 1) {
        feature_names = as.matrix(feature_names)
      }

      for (i in seq_along(feature_names)) {
        other_names = c(feature_names[-i], cols)
        feature_names[[i]] = uniqueify(feature_names[[i]], c(other_names))
      }

      features = list()

      for (j in seq_along(cols)) {
        col = cols[[j]]
        for (i in seq_along(extractors)) {
          nm = feature_names[i, j]
          feature = extractors[[i]](dt[[col]])
          if (is.list(feature)) {
            assert_names(names(feature))
            for (name in names(feature)) {
              features[[paste0(nm, ".", name)]] = feature[[name]]
            }
          } else {
            features[[nm]] = feature
          }
        }
      }

      features = cbind(as.data.table(features), dt)

      if (drop) {
        map(cols, function(col) features[, get("col") := NULL])
      }

      task$select(setdiff(task$feature_names, cols))$cbind(features)
      return(task)
    }
  )
)

#

#' @export
extractor_mean = function(na.rm = TRUE) {
  function(x) {
    map_dbl(unclass(x), function(x) mean(x$value, na.rm = na.rm))
  }
}

#' @export
extractor_max = function(na.rm = TRUE) {
  function(x) {
    map_dbl(unclass(x), function(x) max(x$value, na.rm = na.rm))
  }
}

#' @export
extractor_min = function(na.rm = TRUE) {
  function(x) {
    map_dbl(unclass(x), function(x) min(x$value, na.rm = na.rm))
  }
}

#' @export
extractor_slope = function() {
  extractor_lm()
}

#' @export
extractor_lm = function(intercept = FALSE) {
  function(x) {
    out = map(unclass(x), function(l) coefficients(lm(value ~ arg, data = l)))
    slopes = map_dbl(out, "arg")
    if (!intercept) {
      return(slopes)
    }
    intercepts = map_dbl(out, "(Intercept)")
    list(slope = slopes, intercept = intercepts)
  }
}


if (FALSE) {
  pop = PipeOpFFE$new()
  pop$param_set$values$extractors = list(mean = extract_mean)
  pop$param_set$values$affect_columns = mlr3pipelines::selector_name("NIR")
  task = tsk("fuel")
  x = pop$train(list(task))
}
