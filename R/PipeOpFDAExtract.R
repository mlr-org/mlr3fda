#' @title Extracts Simple Features from Functional Columns
#'
#' @name mlr_pipeops_fda.extract
#'
#' @description
#' This is the class that extracts simple features from functional columns.
#' Note that it only operates on values that were actually observed and does not interpolate.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `drop` :: `logical(1)`\cr
#'   Whether to drop the original `functional` features and only keep the extracted features.
#'   Note that this does not remove the features from the backend, but only from the active
#'   column role `feature`. Initial value is `TRUE`.
#' * `features` :: `list()` | `character()`\cr
#'   A list of features to extract. Each element can be either a function or a string.
#'   If the element if is function it requires the following arguments: `arg` and `value` and returns a `numeric`.
#'   For string elements, the following predefined features are available:
#'   `"mean"`, `"max"`,`"min"`,`"slope"`,`"median"`,`"var"` , `"re"`.
#'   Initial is `c("mean", "max", "min", "slope", "median", "var")`
#' * `left` :: `numeric()`\cr
#'   The left boundary of the window. Initial is `-Inf`.
#'   The window is specified such that the all values >=left and <=right are kept for the computations.
#' * `right` :: `numeric()`\cr
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
#' @export
#' @examples
#' task = tsk("fuel")
#' po_fmean = po("fda.extract", features = "mean")
#' task_fmean = po_fmean$train(list(task))[[1L]]
#'
#' # add more than one feature
#' pop = po("fda.extract", features = c("mean", "median", "var"))
#' task_features = pop$train(list(task))[[1L]]
#'
#' # add a custom feature
#' po_custom = po("fda.extract",
#'   features = list(mean = function(arg, value) mean(value, na.rm = TRUE))
#' )
#' task_custom = po_custom$train(list(task))[[1L]]
#' task_custom
PipeOpFDAExtract = R6Class("PipeOpFDAExtract",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default is `"fda.extract"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.extract", param_vals = list()) {
      param_set = ps(
        drop = p_lgl(tags = c("train", "predict", "required")),
        left = p_dbl(tags = c("train", "predict", "required")),
        right = p_dbl(tags = c("train", "predict", "required")),
        features = p_uty(tags = c("train", "predict", "required"), custom_check = crate(function(x) {
          if (test_character(x)) {
            return(check_subset(x, choices = c("mean", "median", "min", "max", "slope", "var", "re")))
          }
          if (test_list(x)) {
            res = check_list(x, types = c("character", "function"), any.missing = FALSE, unique = TRUE)
            if (!isTRUE(res)) {
              return(res)
            }
            nms = names2(x)
            res = check_names(nms[!is.na(nms)], "unique")
            if (!isTRUE(res)) {
              return(res)
            }
            for (i in seq_along(x)) {
              if (is.function(x[[i]])) {
                res = check_function(x[[i]], args = c("arg", "value"))
                if (!isTRUE(res)) {
                  return(res)
                }
                res = check_names(nms[i])
                if (!isTRUE(res)) {
                  return(res)
                }
              } else {
                res = check_choice(x[[i]], choices = c("mean", "median", "min", "max", "slope", "var", "re"))
                if (!isTRUE(res)) {
                  return(res)
                }
              }
            }
            return(TRUE)
          }
          "Features must be a character or list"
        }))
      )
      param_set$set_values(
        drop = TRUE,
        left = -Inf,
        right = Inf,
        features = c("mean", "max", "min", "slope", "median", "var")
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf", "mlr3misc"),
        feature_types = c("tfd_reg", "tfd_irreg"),
        tags = "fda"
      )
    }
  ),
  private = list(
    .transform = function(task) {
      cols = self$state$dt_columns
      if (length(cols) == 0L) {
        return(task)
      }
      dt = task$data(cols = cols)
      pars = self$param_set$get_values()
      drop = pars$drop
      features = pars$features
      left = pars$left
      right = pars$right
      assert_true(left <= right)

      # handle name clashes of generated features with existing columns
      feature_names = imap_chr(features, function(value, nm) {
        if (is.function(value)) nm else value
      })
      
      # separate handling of random effects as they are computed not rowwise but over all ids
      # random effect variables are last in order of features even if specified otherwise
      if (c('re') %in% feature_names){
        feature_names <- feature_names[!feature_names %in% c('re')]
        feature_names = c(feature_names, 're')
        
        # split random effect in random intercept and slope
        feature_names <- unlist(lapply(feature_names, function(x) {
          if (x == "re") {
            c("random_intercept", "random_slope")
          } else {
            x
          }
        }))
      }
      feature_names = as.vector(t(outer(cols, feature_names, paste, sep = "_")))

      if (anyDuplicated(c(task$col_info$id, feature_names))) {
        unique_names = make.unique(c(task$col_info$id, feature_names), sep = "_")
        feature_names = tail(unique_names, length(feature_names))
        lg$debug(sprintf("Duplicate names found in pipeop %s", self$id), feature_names = feature_names)
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
          var = fvar,
          re = fre
        )
      })
      fextractor = make_fextractor(features)

      features = map(cols, function(col) invoke(fextractor, x = dt[[col]], left = left, right = right))
      features = unlist(features, recursive = FALSE, use.names = FALSE)
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
    
    # Check whether random effects (re) extraction is requested.
    re_requested = some(features, function(x) identical(x, fre))
    # Remove 'fre' from the list for the standard extraction.
    standard_features = if (re_requested) keep(features, function(x) !identical(x, fre)) else features
    
    # Compute standard features 
    res_standard = NULL
    if (length(standard_features) > 0) {
      if (tf::is_reg(x)) {
        interval = ffind(args, left = left, right = right)
        lower = interval[[1L]]
        upper = interval[[2L]]
        if (is.na(lower) || is.na(upper)) {
          res_standard = map(standard_features, function(f) rep(NA_real_, length(x)))
        } else {
          values = tf::tf_evaluations(x)
          # Here we assume that all observations share the same arg window (you may adjust as needed)
          arg = args[lower:upper]
          res_standard = map(seq_along(x), function(i) {
            value = values[[i]]
            map(standard_features, function(f) f(arg = arg, value = value[lower:upper]))
          })
          res_standard = transform_list(res_standard)
        }
      } else {
        values = tf::tf_evaluations(x)
        res_standard = map(seq_along(x), function(i) {
          arg = args[[i]]
          value = values[[i]]
          
          interval = ffind(arg, left = left, right = right)
          lower = interval[[1L]]
          upper = interval[[2L]]
          if (is.na(lower) || is.na(upper)) {
            rep(NA_real_, length(standard_features))
          } else {
            map(standard_features, function(f) f(arg = arg[lower:upper], value = value[lower:upper]))
          }
        })
        res_standard = transform_list(res_standard)
      }
    }
    
    # Compute random effects features if requested 
    res_random = NULL
    if (re_requested) {
      
      # regular grid
      if (tf::is_reg(x)) {
        interval = ffind(args, left = left, right = right)
        lower = interval[[1L]]
        upper = interval[[2L]]
        if (is.na(lower) || is.na(upper)) {
          res_random = map(c('random_intercept','random_slope'), function(f) rep(NA_real_, length(x)))
        } else {
          # Extract relevant interval from the data and unnest into long format.
          x_zoom = tf::tf_zoom(x, begin = left, end = right)
          long_df = as.data.frame(x_zoom, unnest = TRUE)
          res_random = as.data.table(fre(long_df))
        }
      } else{
        # irregular grid
        
        if (left == -Inf | right == Inf) {
          all_args = unlist(args)
          left = min(all_args)
          right = max(all_args)
        }
        
        # Create a container for random effects for every observation
        res_random = data.table(
          random_intercept = rep(NA_real_, length(x)),
          random_slope      = rep(NA_real_, length(x))
        )
        # Extract relevant interval from the data and unnest into long format.
        
        x_zoom = tryCatch({
          suppressWarnings(tf::tf_zoom(x, begin = left, end = right)) # suppress warning from NAs in individual rows
        }, #catch error if there is no data in the selected interval and return NA
        error = function(e) { 
          if (grepl("No data in zoom region", e$message)) {
            return(NULL)
          } else {
            stop(e)
          }
        })
        
        if (!is.null(x_zoom)){
          # identify ids with NA
          NA_ids = is.na(x_zoom)
          
          long_df = as.data.frame(x_zoom, unnest = TRUE)
          # compute random effects, ids with NA are omitted from model estimation
          ranef = fre(long_df)
          # map results to res_random (especially relevant in the presence of NAs)
          res_random[!NA_ids, ] = ranef
        }
      }
      # adapt output format to rowwise feature extraction
      res_random = as.list(res_random)
      }  
    
    # Combine standard and random effects features
    if (!is.null(res_standard) && !is.null(res_random)) {
      # Both parts computed: concatenate the lists 
      combined = c(res_standard, res_random)
    } else if (!is.null(res_standard)) {
      combined = res_standard
    } else if (!is.null(res_random)) {
      combined = res_random
    } 
    combined
  }
}


transform_list = function(x) {
  res = transpose(x)
  map(res, function(x) unlist(x, recursive = FALSE, use.names = FALSE))
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
  # in case there are no values in the interval, it contains the index of the smallest value below
  # and both values in it are identical,
  # e.g. searching the interval (1.1, 1.2) in c(1, 2) returns c(1, 1) which we here convert to an NA interval
  if (it[[1L]] == it[[2L]] && left > x[[it[[1L]]]]) {
    return(rep(NA_integer_, 2L))
  }
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
fmedian = function(arg, value) stats::median(value, na.rm = TRUE)
fslope = function(arg, value) stats::coefficients(stats::lm(value ~ arg))[[2L]]
fvar = function(arg, value) stats::var(value, na.rm = TRUE)
fre = function(long_df){
  lmm = lme4::lmer(value ~ arg + (1 + arg | id), data = long_df)
  re_df = lme4::ranef(lmm)$id
  re_df
}
#' @include zzz.R
register_po("fda.extract", PipeOpFDAExtract)
