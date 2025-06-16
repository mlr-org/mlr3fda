#' @title Extracts Random Effects from Functional Columns
#'
#' @name mlr_pipeops_fda.random_effect
#'
#' @description
#' This is the class that extracts random effects, specifically random intercepts and
#' random slopes, from functional columns. This PipeOp fits a linear mixed model, specifically
#' a random intercept and random slope model, using the [lme4::lmer()] function.
#' The target variable is the value of the functional feature which is regressed on the functional feature's argument
#' while subject id determines the grouping structure. After model estimation, the random effects are extracted and
#' assigned to the correct id.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple].
#'
#' @section Naming:
#' The new names append `_random_intercept` and `_random_slope` to the corresponding column name of the
#' functional feature.
#'
#' @export
#' @examples
#' task = tsk("dti")
#' po_fre = po("fda.random_effect")
#' task_fre = po_fre$train(list(task))[[1L]]
PipeOpFDARandomEffect = R6Class("PipeOpFDARandomEffect",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description
    #' Initializes a new instance of this Class
    #' @param id (`character(1)`) Identifier of the operator, default is `"fda.random_effect"`.
    #' @param param_vals (named `list()`) List of hyperparameter settings, overwriting
    #' default settings set during construction.
    initialize = function(id = "fda.random_effect", param_vals = list()) {
      super$initialize(
        id = id,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf", "lme4"),
        feature_types = c("tfd_reg", "tfd_irreg"),
        tags = "fda"
      )
    }
  ),
  private = list(
    .transform_dt = function(dt, levels) {
      cols = imap(dt, function(x, nm) {
        tab = as.data.frame(x, unnest = TRUE)
        model = invoke(lme4::lmer, .args = list(formula = value ~ arg + (1 + arg | id), data = tab))
        feats = lme4::ranef(model)$id
        setDT(feats)
        setnames(feats, sprintf("%s_%s", nm, c("random_intercept", "random_slope")))
      })
      setDT(unlist(unname(cols), recursive = FALSE))
    }
  )
)

#' @include zzz.R
register_po("fda.random_effect", PipeOpFDARandomEffect)
