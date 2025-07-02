#' @title Discrete Wavelet transform features
#' @name mlr_pipeops_fda.wavelets
#'
#' @description
#' This `PipeOp` extracts discrete wavelet transform coefficients from functional columns.
#' For more details, see [wavelets::dwt()], which is called internally.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `filter` :: `character(1)` | `numeric()` | [wavelets::wt.filter()]\cr
#'   Specifies which filter should be used. Must be either [wavelets::wt.filter()] object, an even numeric vector or a
#'   string. In case of a string must be one of `"d"`|`"la"`|`"bl"`|`"c"` followed by an even number for the level of
#'   the filter. The level of the filter needs to be smaller or equal then the time-series length.
#'   For more information and acceptable filters see `help(wt.filter)`. Defaults to `"la8"`.
#' * `n.levels` :: `integer(1)`\cr
#'   An integer specifying the level of the decomposition.
#' * `boundary` :: `character(1)`\cr
#'   Boundary to be used. `"periodic"` assumes circular time series, for `"reflection"` the series is extended to twice
#'   its length. Default is `"periodic"`.
#' * `fast` :: `logical(1)`\cr
#'   Should the pyramid algorithm be calculated with an internal C function? Default is `TRUE`.
#' @export
#' @examples
#' task = tsk("fuel")
#' po_wavelets = po("fda.wavelets")
#' task_wavelets = po_wavelets$train(list(task))[[1L]]
#' task_wavelets$data()
PipeOpFDAWavelets = R6Class("PipeOpFDAWavelets",
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
          default = "la8", tags = c("train", "predict"), custom_check = crate(function(x) {
            if (test_class(x, "wt.filter")) {
              return(TRUE)
            }
            if (test_string(x)) {
              choices = c(
                paste0("d", c(2, 4, 6, 8, 10, 12, 14, 16, 18, 20)),
                paste0("la", c(8, 10, 12, 14, 16, 18, 20)),
                paste0("bl", c(14, 18, 20)),
                paste0("c", c(6, 12, 18, 24, 30)),
                "haar"
              )
              return(check_choice(x, choices))
            }
            if (test_numeric(x) && length(x) %% 2L == 0L) {
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
        feature_types = c("tfd_reg", "tfd_irreg"),
        tags = "fda"
      )
    }
  ),

  private = list(
    .transform_dt = function(dt, levels) {
      pars = self$param_set$get_values()
      filter = pars$filter %??% "la8"

      cols = imap(dt, function(x, nm) {
        feats = map_dtr(
          tf::tf_evaluations(x),
          function(x) {
            wt = invoke(wavelets::dwt, X = x, .args = pars)
            feats = unlist(c(wt@W, wt@V[[wt@level]]), use.names = FALSE)
            as.data.table(t(feats))
          },
          .fill = TRUE
        )
        setnames(feats, sprintf("%s_wav_%s_%i", nm, filter, seq_len(ncol(feats))))
      })
      setDT(unlist(unname(cols), recursive = FALSE))
    }
  )
)

#' @include zzz.R
register_po("fda.wavelets", PipeOpFDAWavelets)
