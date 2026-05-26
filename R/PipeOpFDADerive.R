#' @title Derivatives of Functional Columns
#'
#' @name mlr_pipeops_fda.derive
#'
#' @description
#' Computes derivatives of functional features via [tf::tf_derive()].
#' For `tfd` inputs derivatives are obtained by finite differencing of the function evaluations,
#' for `tfb` inputs by finite differencing of the basis functions.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `order` :: `integer(1)`\cr
#'   Order of the derivative. Must be a positive integer. Initial value is `1`.
#' * `arg` :: `numeric()`\cr
#'   Optional grid to use for the finite differences. If `NULL` (the default), the argument grid of each functional
#'   column is used. For `tfd_irreg` inputs, supplying `arg` interpolates the data to a common grid before
#'   differentiating.
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' po_deriv = po("fda.derive", order = 1)
#' task_deriv = po_deriv$train(list(task))[[1L]]
#' task_deriv$data(cols = c("NIR", "UVVIS"))
PipeOpFDADerive = R6Class(
  "PipeOpFDADerive",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.derive"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.derive", param_vals = list()) {
      param_set = ps(
        order = p_int(lower = 1L, tags = c("train", "predict", "required")),
        arg = p_uty(
          tags = c("train", "predict"),
          custom_check = crate(\(x) check_numeric(x, finite = TRUE, any.missing = FALSE, min.len = 1L, sorted = TRUE))
        )
      )
      param_set$set_values(order = 1L)

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
      for (j in seq_along(dt)) {
        set(dt, j = j, value = invoke(tf::tf_derive, f = dt[[j]], .args = pars))
      }
      dt
    }
  )
)

#' @include zzz.R
register_po("fda.derive", PipeOpFDADerive)
