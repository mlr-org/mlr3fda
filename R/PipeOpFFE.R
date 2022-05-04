#' @title (F)unctional (F)eature (E)xtractor
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
#' @export
PipeOpFFE = R6Class("PipeOpFFE",
  inherit = mlr3pipelines::PipeOpTaskPreprocSimple,
  public = list(
    initialize = function(id = "ffe", param_vals = list(), can_subset) {
      param_set = ps(
        extractors = p_uty(tags = c("train", "predict", "required"), custom_check = check_named_functions),
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


      for (j in seq_along(cols)) {
        col = cols[[j]]
        for (i in seq_along(extractors)) {
          nm = feature_names[i, j]
          extractor = extractors[[i]]
          # TODO: should not make this dbl assumption here?
          # TODO take care of name clashes here (?)
          features = map(unclass(dt[[col]]), function(x) invoke(extractor, .args = x))
          # maybe use simplify2array (?) what is the difference?
          features = pmap(features, c)
          if (length(features) > 1L) {
            nm = paste(nm, seq_along(features))
          }
          features = set_names(as.data.table(features), nm)
          dt = cbind(dt, features)

        }
      }


      if (drop) {
        map(cols, function(col) dt[, get("col") := NULL])
      }

      task$select(setdiff(task$feature_names, cols))$cbind(dt)
      return(task)
    }
  )
)

#

#' @export
extract_mean = function(arg, value) {
  mean(value, na.rm = TRUE)
}

#' @export
extract_max = function(arg, value) {
  max(value, na.rm = TRUE)
}

#' @export
extract_min = function(arg, value) {
  min(value, na.rm = TRUE)
}

#' @export
extract_slope = function(arg, value) {
  coefficients(lm(value ~ arg))[[2L]]
}

check_named_functions = function(x) {
  assert_list(x, any.missing = FALSE, min.len = 1L, names = "unique")
  all_functions = all(map_lgl(x, is.function))
  correct_args = map_lgl(x, function(x) test_subset(formalArgs(x), c("arg", "value")))
  if (all_functions && all(correct_args)) {
    return(TRUE)
  }
  "Must be a list of functions with parameter 'value' and 'arg'."
}


if (FALSE) {
  pop = PipeOpFFE$new()
  pop$param_set$values$extractors = list(mean = extract_mean)
  pop$param_set$values$affect_columns = mlr3pipelines::selector_name("NIR")
  task = tsk("fuel")
  x = pop$train(list(task))
}
