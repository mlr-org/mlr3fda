#' @title Time Series Feature Extraction
#' @name mlr_pipeops_fda.tsfeats
#'
#' @description
#' This `PipeOp` extracts time series features from functional columns.
#'
#' For more details, see [tsfeatures::tsfeatures()], which is called internally.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `features` :: `character()`\cr
#' Function names which return numeric vectors of features.
#' All features returned by these functions must be named if they return more than one feature.
#' Default is `c("frequency", "stl_features", "entropy", "acf_features")`.
#' * `scale` :: `logical(1)`\cr
#' If `TRUE`, data is scaled to mean 0 and sd 1 before features are computed. Default is `TRUE`.
#' * `trim` :: `logical(1)`\cr
#' If `TRUE`, data is trimmed by `trim_amount` before features are computed.
#' Values larger than `trim_amount` in absolute value are set to `NA`. Default is `FALSE`.
#' * `trim_amount` :: `numeric(1)`\cr
#' Default level of trimming. Default is `0.1`.
#' * `parallel` :: `logical(1)`\cr
#' If `TRUE`, the features are computed in parallel. Default is `FALSE`.
#' * `multiprocess` :: `any`\cr
#' The function from the future package to use for parallel processing. Default is [future::multisession()].
#' * `na.action` :: `any`\cr
#' A function to handle missing values. Default is [stats::na.pass()].
#'
#' @section Naming:
#' The new names generally append a `_{feature}` to the corresponding column name.
#' If a column was called `"x"` and the feature is `"trend"`, the corresponding new column will
#' be called `"x_trend"`.
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' po_tsfeats = po("fda.tsfeats")
#' task_tsfeats = po_tsfeats$train(list(task))[[1L]]
#' task_tsfeats$data()
PipeOpFDATsfeatures = R6Class("PipeOpFDATsfeatures",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default is `"fda.tsfeats"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.tsfeats", param_vals = list()) {
      param_set = ps(
        features = p_uty(
          default = c("frequency", "stl_features", "entropy", "acf_features"),
          tags = "train",
          custom_check = crate(function(x) check_character(x, any.missing = FALSE, min.len = 1L))
        ),
        scale = p_lgl(default = TRUE, tags = c("train", "predict")),
        trim = p_lgl(default = FALSE, tags = c("train", "predict")),
        trim_amount = p_dbl(default = 0.1, tags = c("train", "predict"), depends = quote(trim == TRUE)), # nolint
        parallel = p_lgl(default = FALSE, tags = c("train", "predict")),
        multiprocess = p_uty(
          default = future::multisession,
          tags = c("train", "predict"),
          depends = quote(parallel == TRUE), # nolint
          custom_check = check_function
        ),
        na.action = p_uty(default = stats::na.pass, tags = c("train", "predict"), custom_check = check_function)
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf", "tsfeatures"),
        feature_types = c("tfd_reg", "tfd_irreg"),
        tags = "fda"
      )
    }
  ),

  private = list(
    .transform_dt = function(dt, levels) {
      pars = self$param_set$get_values()

      cols = imap(dt, function(x, nm) {
        tslist = tf::tf_evaluations(x)
        feats = invoke(tsfeatures::tsfeatures, tslist = tslist, .args = pars)
        setDT(feats)
        setnames(feats, sprintf("%s_%s", nm, names(feats)))
      })
      setDT(unlist(unname(cols), recursive = FALSE))
    }
  )
)

#' @include zzz.R
register_po("fda.tsfeats", PipeOpFDATsfeatures)
