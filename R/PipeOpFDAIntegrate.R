#' @title Functional Integral Features
#'
#' @name mlr_pipeops_fda.integrate
#'
#' @description
#' Computes the definite integral of functional features via [tf::tf_integrate()].
#' The integral summarizes each curve into a single scalar, namely the (signed) area under the curve over its domain.
#'
#' By default the integral is taken over the full domain of each curve. The `lower` and `upper` parameters restrict
#' the integration to a window. The same operation is applied during training and prediction.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `lower` :: `numeric(1)`\cr
#'   The left boundary of the integration window. If not set, the domain start of each curve is used.
#' * `upper` :: `numeric(1)`\cr
#'   The right boundary of the integration window. If not set, the domain end of each curve is used.
#'
#' @section Naming:
#' The new names generally append a `_integral` to the corresponding column name.
#' If a column was called `"x"`, the corresponding new column will be called `"x_integral"`.
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' po_integrate = po("fda.integrate")
#' task_integrate = po_integrate$train(list(task))[[1L]]
#' task_integrate$data(cols = c("NIR_integral", "UVVIS_integral"))
PipeOpFDAIntegrate = R6Class(
  "PipeOpFDAIntegrate",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.integrate"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.integrate", param_vals = list()) {
      param_set = ps(
        lower = p_dbl(tags = c("train", "predict")),
        upper = p_dbl(tags = c("train", "predict"))
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf"),
        feature_types = c("tfd_reg", "tfd_irreg"),
        tags = "fda"
      )
    }
  ),
  private = list(
    .transform_dt = function(dt, levels) {
      pars = self$param_set$get_values()
      setcbindlist(imap(dt, function(x, nm) {
        integral = invoke(tf::tf_integrate, f = x, .args = pars)
        integral_dt = as.data.table(integral)
        setnames(integral_dt, sprintf("%s_integral", nm))
      }))
    }
  )
)

#' @include zzz.R
register_po("fda.integrate", PipeOpFDAIntegrate)
