#' @title Functional Principal Component Analysis
#' @name mlr_pipeops_fda.tsfeats
#'
#' @description
#' This `PipeOp` applies ...
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * ...
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
PipeOpTSFeatures = R6Class("PipeOpTSFeatures",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default is `"fda.tsfeats"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.tsfeats", param_vals = list()) {
      param_set = ps(
        feats = p_uty(
          default = c("frequency", "stl_features", "entropy", "acf_features"),
          tags = "train"
        ),
        scale = p_lgl(default = TRUE, tags = c("train", "predict")),
        trim = p_lgl(default = TRUE, tags = c("train", "predict")),
        trim_amount = p_dbl(
          default = 0.1, tags = c("train", "predict"), depends = quote(trim == TRUE)
        ),
        parallel = p_lgl(default = FALSE, tags = c("train", "predict")),
        multiprocess = p_uty(
          tags = c("train", "predict"), depends = quote(parallel == TRUE)
        ),
        na.action = p_uty(tags = c("train", "predict"))
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf", "tsfeatures"),
        feature_types = "tfd_reg",
        tags = "fda"
      )
    }
  ),

  private = list(
    .transform_dt = function(dt, levels) {
      require_namespaces(
        "tsfeatures", "To use this PipeOp, please install the following package: %s"
      )

      pars = self$param_set$get_values()

      cols = imap(dt, function(x, nm) {
        tslist = tf::tf_evaluations(x)
        feats = invoke(tsfeatures::tsfeatures, tslist = tslist, .args = pars)
        setDT(feats)
        setnames(feats, sprintf("%s_%s", nm, names(feats)))
      })
      cols = unlist(unname(cols), recursive = FALSE)
      setDT(cols)
    }
  )
)

#' @include zzz.R
register_po("fda.tsfeats", PipeOpTSFeatures)
