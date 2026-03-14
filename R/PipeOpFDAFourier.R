#' @title Fast Fourier transform features
#' @name mlr_pipeops_fda.fourier
#'
#' @description
#' This `PipeOp` extracts features from functional columns based on the fast Fourier transform.
#' For more details, see [stats::fft()], which is called internally.
#'
#' The FFT decomposes the functional data into frequency domain components.
#' The resulting complex coefficients are then converted to either amplitude (magnitude) or phase values.
#' Only the one-sided spectrum is returned (DC through Nyquist), since the FFT of real-valued signals is
#' symmetric (Hermitian symmetry). For the amplitude spectrum, only the interior positive frequency components are
#' doubled to account for the energy in their symmetric counterparts. The DC and Nyquist components are not doubled
#' because they have no conjugate pair (Oppenheim and Schafer, 2010).
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `trafo_coeff` :: `character(1)`\cr
#'   Which transformation of the complex frequency domain representation should be calculated.
#'   Must be one of `"amplitude"` or `"phase"`. `"amplitude"` returns the magnitude of the Fourier coefficients.
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
    #'   Identifier of resulting object, default is `"fda.fourier"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.fourier", param_vals = list()) {
      param_set = ps(
        trafo_coeff = p_fct(levels = c("phase", "amplitude"), tags = c("train", "predict"))
      )
      param_set$set_values(trafo_coeff = "phase")

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
      trafo_coeff = self$param_set$get_values()$trafo_coeff

      setcbindlist(imap(dt, function(x, nm) {
        values = tf::tf_evaluations(x)
        n = length(values[[1L]])
        # one-sided spectrum: DC + positive frequencies + Nyquist (for even n)
        n_onesided = n %/% 2L + 1L
        fft_coeff = map_dtr(values, function(v) {
          coeff = stats::fft(v)[seq_len(n_onesided)] / n
          res = switch(
            trafo_coeff,
            amplitude = {
              amp = Mod(coeff)
              # double positive frequencies (exclude DC; also exclude Nyquist for even n)
              double_end = if (n %% 2L == 0L) n_onesided - 1L else n_onesided
              if (double_end >= 2L) {
                amp[2L:double_end] = amp[2L:double_end] * 2
              }
              amp
            },
            phase = {
              mag = Mod(coeff)
              phase = Arg(coeff) * 180 / pi
              phase[mag < max(mag) * 1e-4] = 0
              phase
            }
          )
          as.data.table(t(res))
        })
        setnames(fft_coeff, sprintf("%s_fft_%s_%i", nm, trafo_coeff, seq_len(ncol(fft_coeff))))
      }))
    }
  )
)

#' @include zzz.R
register_po("fda.fourier", PipeOpFDAFourier)
