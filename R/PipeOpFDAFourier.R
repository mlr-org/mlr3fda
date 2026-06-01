#' @title Fast Fourier Transform Features
#'
#' @name mlr_pipeops_fda.fourier
#'
#' @description
#' This `PipeOp` extracts Fourier coefficients from functional columns.
#' For more details, see [stats::fft()], which is called internally.
#' Only the one-sided spectrum is returned since the input is real-valued (Oppenheim and Schafer, 2010).
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `type` :: `character(1)`\cr
#'   Which feature to extract from the Fourier coefficients. `"amplitude"` returns the magnitude.
#'   `"phase"` returns the phase shift in degrees (values in \[-180, 180\]). Initial value is `"phase"`.
#'
#' @references `r format_bib("oppenheim2010discrete")`
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' po_fourier = po("fda.fourier")
#' task_fourier = po_fourier$train(list(task))[[1L]]
#' task_fourier$data()
PipeOpFDAFourier = R6Class(
  "PipeOpFDAFourier",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.fourier"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.fourier", param_vals = list()) {
      param_set = ps(
        type = p_fct(levels = c("phase", "amplitude"), tags = c("train", "predict"))
      )
      param_set$set_values(type = "phase")

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf"),
        feature_types = "tfd_reg",
        tags = "fda"
      )
    }
  ),

  private = list(
    .transform_dt = function(dt, levels) {
      type = self$param_set$get_values()$type

      setcbindlist(imap(dt, function(x, nm) {
        mat = t(as.matrix(x))
        n = nrow(mat)
        n_onesided = n %/% 2L + 1L
        coeff = stats::mvfft(mat)[seq_len(n_onesided), , drop = FALSE] / n
        res = switch(
          type,
          amplitude = {
            amp = Mod(coeff)
            # double interior positive frequencies (DC and Nyquist have no conjugate pair)
            double_end = if (n %% 2L == 0L) n_onesided - 1L else n_onesided
            if (double_end >= 2L) {
              amp[2L:double_end, ] = amp[2L:double_end, , drop = FALSE] * 2
            }
            amp
          },
          phase = {
            mag = Mod(coeff)
            phase = Arg(coeff) * 180 / pi
            threshold = rep(apply(mag, 2L, max) * 1e-4, each = n_onesided)
            phase[mag < threshold] = 0
            phase
          }
        )
        fft_coeff = as.data.table(t(res))
        setnames(fft_coeff, sprintf("%s_fft_%s_%i", nm, type, seq_col(fft_coeff)))
      }))
    }
  )
)

#' @include zzz.R
register_po("fda.fourier", PipeOpFDAFourier)
