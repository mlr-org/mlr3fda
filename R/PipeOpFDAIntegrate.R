#' @title Functional Integral Features
#'
#' @name mlr_pipeops_fda.integrate
#'
#' @description
#' Computes the definite integral of functional features via [tf::tf_integrate()].
#' The integral summarizes each curve into a single scalar, namely the (signed) area under the curve over its domain.
#'
#' By default, regular curves are integrated over their full domain,
#' and irregular curves over their own observed range, i.e., from their first to their last observed argument.
#' Integrals of irregular curves may therefore cover different ranges.
#' The `lower` and `upper` parameters restrict the integration to a common window.
#' Curves that are not observed over the whole window get an integral of `NA`.
#' The same operation is applied during training and prediction.
#'
#' @section State:
#' The `$state` is a named `list` with the `$state` elements inherited from
#' [`PipeOpTaskPreproc`][mlr3pipelines::PipeOpTaskPreproc].
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `lower` :: `numeric(1)`\cr
#'   The left boundary of the integration window.
#'   If not set, the domain start is used for regular curves and the first observed argument for irregular curves.
#' * `upper` :: `numeric(1)`\cr
#'   The right boundary of the integration window.
#'   If not set, the domain end is used for regular curves and the last observed argument for irregular curves.
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
        lower = p_dbl(tags = c("train", "predict", "integrate")),
        upper = p_dbl(tags = c("train", "predict", "integrate"))
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
      pars = self$param_set$get_values(tags = "integrate")
      if (!is.null(pars$lower) && !is.null(pars$upper) && pars$lower > pars$upper) {
        error_config("'lower' must not be greater than 'upper'.")
      }
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
