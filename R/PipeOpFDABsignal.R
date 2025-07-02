#' @title B-spline Feature Extraction
#' @name mlr_pipeops_fda.bsignal
#'
#' @description
#' This `PipeOp` extracts features from functional data using B-spline basis functions.
#' The extracted features are B-spline coefficients that represent the functional data in the B-spline basis space.
#' For more details, see [FDboost::bsignal()], which is called internally.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `inS` :: `character(1)`\cr
#'   Type of effect in the covariate index: one of `"smooth"`, `"linear"`, `"constant"`. Default `"smooth"`.
#' * `knots` :: `numeric()`\cr
#'   Either the number of interior knots or a vector of their positions.
#' * `boundary.knots` :: `numeric(2)`\cr
#'   Boundary points at which to anchor the B-spline basis.
#'   Lower and upper boundary points for the spline basis. Defaults to the range of the data.
#' * `degree` :: `integer(1)`\cr
#'   The degree of the regression spline. Default is `3L`.
#' * `differences` :: `integer(1)`\cr
#'   Order of difference penalty. Default is `1L`.
#' * `df` :: `numeric(1)`\cr
#'    Trace of the hat matrix, controlling smoothness. Default is `4`.
#' * `lambda` :: `any`\cr
#'   Smoothing parameter of the penalty term.
#' * `center` :: `logical(1)`\cr
#'   Reparameterize the unpenalized part to zero-mean? Default is `FALSE`.
#' * `cyclic` :: `logical(1)`\cr
#'   If true the fitted coefficient function coincides at the boundaries.
#' * `Z` :: `any`\cr
#'   Custom transformation matrix for the spline design.
#' * `penalty` :: `character(1)`\cr
#'   The penalty type: `"ps"` (P-spline) or `"pss"` (shrinkage). DEfault is `"ps"`.
#' * `check.ident` :: `logical(1)`\cr
#'   Use checks for identifiability of the effect. Default is `FALSE`.
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' po_bsignal = po("fda.bsignal")
#' task_bsignal = po_bsignal$train(list(task))[[1L]]
#' task_bsignal$data()
PipeOpFDABsignal = R6Class("PipeOpFDABsignal",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default is `"fda.bsignal"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.bsignal", param_vals = list()) {
      param_set = ps(
        inS = p_fct(default = "smooth", c("smooth", "linear", "constant"), tags = c("train", "predict")),
        knots = p_uty(
          default = 10L,
          tags = c("train", "predict"),
          custom_check = crate(function(x) check_numeric(x, min.len = 1))
        ),
        boundary.knots = p_uty(
          default = NULL,
          special_vals = list(NULL),
          tags = c("train", "predict"),
          custom_check = crate(function(x) check_numeric(x, len = 2L, null.ok = TRUE))
        ),
        degree = p_int(default = 3L, tags = c("train", "predict")),
        differences = p_int(1L, default = 1L, tags = c("train", "predict")),
        df = p_dbl(default = 4, tags = c("train", "predict")),
        lambda = p_uty(default = NULL, tags = c("train", "predict")),
        center = p_lgl(default = FALSE, tags = c("train", "predict")),
        cyclic = p_lgl(default = FALSE, tags = c("train", "predict")),
        Z = p_uty(default = NULL, tags = c("train", "predict")),
        penalty = p_fct(default = "ps", c("ps", "pss"), tags = c("train", "predict")),
        check.ident = p_lgl(default = FALSE, tags = c("train", "predict"))
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf", "mboost", "FDboost"),
        feature_types = "tfd_reg",
        tags = "fda"
      )
    }
  ),

  private = list(
    .transform_dt = function(dt, levels) {
      pars = self$param_set$get_values()

      cols = imap(dt, function(x, nm) {
        x = as.matrix(x)
        blrn = invoke(FDboost::bsignal, x = x, s = seq_len(ncol(x)), .args = pars)
        bsignal = mboost::extract(object = blrn, what = "design") # get the design matrix of the base learner
        feats = as.data.table(bsignal)
        setnames(feats, sprintf("%s_bsig_%i", nm, seq_len(ncol(feats))))
      })
      setDT(unlist(unname(cols), recursive = FALSE))
    }
  )
)

#' @include zzz.R
register_po("fda.bsignal", PipeOpFDABsignal)
