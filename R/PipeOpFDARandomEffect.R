#' @title Extracts Random Effects from Functional Columns
#' 
#' @name mlr_pipeops_fda.randomeffect
#' 
#' @description
#' This is the class that extracts random effects, specifically random intercepts and
#' random slopes, from functional columns. This PipeOp fits a linear mixed model, specifically 
#' a random intercept and random slope model, using the `lme4::lmer()` function.
#' The target variable is the value of the functional feature which is regressed on the functional feature's argument while subject id 
#' determines the grouping structure. After model estimation, the random effects are extracted and assigned to the correct id. 
#' 
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `drop` :: `logical(1)`\cr
#'   Whether to drop the original `functional` features and only keep the extracted random effects.
#'   Note that this does not remove the features from the backend, but only from the active
#'   column role `feature`. Initial value is `TRUE`.
#'   `left` :: `numeric()`\cr
#'   The left boundary of the window. Initial is `-Inf`.
#'   The window is specified such that the all values >=left and <=right are kept for the computations.
#' * `right` :: `numeric()`\cr
#'   The right boundary of the window. Initial is `Inf`.
#'   
#' @section Naming:
#' The new names generally append `_random_intercept` and `_random_slope` to the corresponding column name of the functional feature.
#'  
#' @export
#' @examples
#' task = tsk("dti")
#' po_fre = po("fda.randomeffect", drop = FALSE)
#' task_fre = po_fre$train(list(task))[[1L]]

PipeOpFDARandomEffect = R6Class("PipeOpFDARandomEffect",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description
    #' Initializes a new instance of this Class
    #' @param id (`character(1)`) Identifier of the operator, default is `"fda.randomeffect"`.
    #' @param param_vals (named `list()`) List of hyperparameter settings, overwriting 
    #' default settings set during construction.
    initialize = function(id = "fda.randomeffect", param_vals = list()) {
      param_set = ps(
        drop = p_lgl(tags = c("train", "predict", "required")),
        left = p_dbl(tags = c("train", "predict", "required")),
        right = p_dbl(tags = c("train", "predict", "required"))
        )
      param_set$set_values(
        drop = TRUE,
        left = -Inf,
        right = Inf
      )
      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf", "lme4"),
        feature_types = c("tfd_reg", "tfd_irreg"),
        tags = "fda"
      )
    }
  ),
  private = list(
    .transform_dt = function(dt, levels) {
      pars = self$param_set$get_values()
      drop = pars$drop
      left = pars$left
      right = pars$right
      assert_true(left <= right)
      
      cols = imap(dt, function(x, nm){
        # create a container for random effects for every observation
        res_random = data.table(
          random_intercept = rep(NA_real_, length(x)),
          random_slope      = rep(NA_real_, length(x))
        )
        all_args = unlist(tf::tf_arg(x))
        # set domain for left and right window
        if (left == -Inf) {
          left = min(all_args)
        }
        if (right == Inf){
          right = max(all_args)
        }
        # zoom the tfd vector.
        x_zoom = tryCatch({
          suppressWarnings(tf::tf_zoom(x, begin = left, end = right))
          }, error = function(e) {
            if (grepl("No data in zoom region", conditionMessage(e))){ 
              return(NULL) 
            } else {
              message("tf_zoom encountered an error: ", conditionMessage(e))
              stop(e)
            }
          }
        )
        if (!is.null(x_zoom)) {
          # unnest the zoomed data into long format
          long_df = as.data.frame(x_zoom, unnest = TRUE)
          # compute random effects, ids with NA are omitted from model estimation
          raneff = franeff(long_df)
          if (!is.null(raneff)){
            # map random effects back to correct id (applies in presence of NAs)
            ids_available = as.numeric(rownames(raneff))
            res_random[ids_available, ] = raneff
          }
        }
        new_names = paste0(nm, "_", c("random_intercept", "random_slope"))
        setnames(res_random, old = names(res_random), new = new_names)
      })
      dt_new = setDT(unlist(unname(cols), recursive = FALSE))
      if (!drop) {
        dt_new = cbind(dt, dt_new)
      }
      dt_new
    }
  )
)

franeff = function(long_df){
  lmm = tryCatch({
      lmm <- invoke(lme4::lmer, 
                    .args = list(formula = value ~ arg + (1 + arg | id), 
                                 data = long_df))
      }, error = function(e) {
      message("lmer encountered an error: ", conditionMessage(e))
      return(NULL)
    }
  )
  if (is.null(lmm)){
    return(NULL)
  } else {
  re_df = lme4::ranef(lmm)$id
  re_df
  }
}

#' @include zzz.R
register_po("fda.randomeffect", PipeOpFDARandomEffect)
