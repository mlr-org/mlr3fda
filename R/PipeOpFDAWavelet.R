#' @title Discrete Wavelet transform features
#' @name mlr_pipeops_fda.wavelets
#'
#' @description
#' This `PipeOp` extracts discrete wavelet transform coefficients from functional columns.
#'
#' For more details, see [wavelets::dwt()], which is called internally.
#'
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' po_wavelets = po("fda.wavelets")
#' task_wavelets = po_wavelets$train(list(task))[[1L]]
#' task_wavelets$data()
PipeOpFDAWavelets = R6Class(
  "PipeOpFDAWavelets",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default is `"fda.tsfeats"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.wavelets", param_vals = list()) {
      param_set = ps(
        # `d`|`la`|`bl`|`c` follwed by an even number for the level of the filter
        # filter.vals = c(
        #   paste0("d", c(2, 4, 6, 8, 10, 12, 14, 16, 18, 20)),
        #   paste0("la", c(8, 10, 12, 14, 16, 18, 20)),
        #   paste0("bl", c(14, 18, 20)),
        #   paste0("c", c(6, 12, 18, 24, 30)),
        #   "haar"
        # )
        filter = p_uty(default = "la8"),
        n.levels = p_uty(),
        boundary = p_fct(default = "periodic", c("periodic", "reflection")),
        fast = p_lgl(default = TRUE)
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf", "wavelets"),
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
        map_dtc(tslist, function(x) {
          wt = invoke(wavelets::dwt, X = x, .args = pars)
          unlist(c(wt@W, wt@V[[wt@level]]))
        })
        browser()
        setDT(feats)
        setnames(feats, sprintf("%s_%s", nm, names(feats)))
      })
      browser()
    }
  )
)

#' @include zzz.R
register_po("fda.wavelets", PipeOpFDAWavelets)
