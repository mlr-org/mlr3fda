#' (F)unctional (F)eature (E)xtractor
#'
#' @usage NULL
#' @name mlr_pipeops_ffe
#' @format [`R6Class`] object inheriting from
#' [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]
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
#'
#' @section Methods:
#' Only methods inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]/
#' [`PipeOp`][mlr3pipelines::PipeOp]
#'
#' @export
PipeOpFFE = R6Class("PipeOpFFE",
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(

    #' @description Initializes a new instance of this Class.
    #' @param id ()`character(1)`)\cr
    #'   Identifier of resulting object, default `"ffe"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #' @param .extractors (named `list()`)\cr
    #'   Named list of functions, that extract the features. The names are the suffixes that are
    #'   appended to the original column names, and the values are the feature extractors and must
    #'   return a list with values (i.e. the features). If there is more than one features, the
    #'   corresponding number is additionally suffixed to the name of the extracted feature.
    initialize = function(id = "ffe", param_vals = list()) {

      assert_list(.extractors, min.len = 1L)
      extractor_params = extract_params(.extractors)
      private$.extractors = .extractors

      param_set = ps(
        drop = p_lgl(default = TRUE, tags = c("train"))
      )$add(extractor_params)

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
      params = self$param_set$values
      extractors = imap(
        private$.extractors,
        function(extractor, name) {

          pars = params[names(params) %in% paste0(name, ".", formalArgs(extractor))]
          nms = gsub(sprintf("^%s\\.", name), "", names(pars))
          pars = set_names(pars, nms)
          invoke(extractor, .args = pars)
        }
      )

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
      if (length(cols) == 1L) {
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
        feature_names[[i]] = uniqueify_once(feature_names[[i]], c(other_names))
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
    },
    .extractors = NULL
  )
)

#

#' @export
extractor_mean = function(na.rm = TRUE) { # nolint
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


#' (F)unctional (F)eature (E)xtractor
#'
#' @usage NULL
#' @name mlr_pipeops_ffe
#' @format [`R6Class`] object inheriting from
#' [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]
#'
#' @section Parameters:
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
#' @section Methods:
#' Only methods inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple]/
#' [`PipeOp`][mlr3pipelines::PipeOp]
#'
#' @export
PipeOpFFE = R6Class("PipeOpFFE",
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(

    #' @description Initializes a new instance of this Class.
    #' @param id ()`character(1)`)\cr
    #'   Identifier of resulting object, default `"ffe"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
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

