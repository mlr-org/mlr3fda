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
    #'   Identifier of resulting object, default is `"fda.wavelets"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.wavelets", param_vals = list()) {
      param_set = ps(
        filter = p_uty(
          default = "la8",
          tags = c("train", "predict"),
          custom_check = crate(function(x) {
            if (test_class(filter, "wt.filter")) {
              return(TRUE)
            }
            if (test_string(filter)) {
              choices = c(
                paste0("d", c(2, 4, 6, 8, 10, 12, 14, 16, 18, 20)),
                paste0("la", c(8, 10, 12, 14, 16, 18, 20)),
                paste0("bl", c(14, 18, 20)),
                paste0("c", c(6, 12, 18, 24, 30)),
                "haar"
              )
              return(check_choice(x, choices))
            }
            if (test_numeric(filter) && length(filter) %% 2L == 0L) {
              return(TRUE)
            }
            "Must be either a string, an even numeric vector or wavelet filter object"
          })
        ),
        n.levels = p_int(tags = c("train", "predict")),
        boundary = p_fct(default = "periodic", c("periodic", "reflection"), tags = c("train", "predict")),
        fast = p_lgl(default = TRUE, tags = c("train", "predict"))
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf", "wavelets"),
        feature_types = "tfd_reg",
        tags = "fda"
      )
    }
  ),

  private = list(
    .transform_dt = function(dt, levels) {
      pars = self$param_set$get_values()

      cols = imap(dt, function(x, nm) {
        feats = map_dtr(tf::tf_evaluations(x), function(x) {
          wt = invoke(wavelets::dwt, X = x, .args = pars)
          feats = unlist(c(wt@W, wt@V[[wt@level]]), use.names = FALSE)
          as.data.table(t(feats))
        })
        setnames(feats, sprintf("%s_wav_%i", nm, seq_len(ncol(feats))))
      })
      setDT(unlist(unname(cols), recursive = FALSE))
    }
  )
)

#' @include zzz.R
register_po("fda.wavelets", PipeOpFDAWavelets)
