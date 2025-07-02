#' @title Zoom In/Out on Functional Columns
#' @name mlr_pipeops_fda.zoom
#'
#' @description
#' Zoom in or out on functional features by restricting their domain to a specified window.
#' This operation extracts a subset of each function by defining new lower and upper boundaries,
#' effectively cropping the functional data to focus on a specific region of interest.
#' Calls [tf::tf_zoom()] from package \CRANpkg{tf}.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `begin` :: `numeric()`\cr
#'   The lower limit of the domain. Can be a single value applied to all
#'   functional columns, or a numeric of length equal to the number of observations.
#'   The window includes all values where argument >= `begin`. If not specified,
#'   defaults to the lower limit of each function's domain.
#' * `end` :: `numeric()`\cr
#'   The upper limit of the domain.
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' pop = po("fda.zoom", begin = 50, end = 100)
#' task_zoom = pop$train(list(task))[[1L]]
#' task_zoom$data()
PipeOpFDAZoom = R6Class("PipeOpFDAZoom",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.zoom"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.zoom", param_vals = list()) {
      param_set = ps(
        begin = p_uty(
          tags = c("train", "predict"),
          custom_check = crate(function(x) check_numeric(x, finite = TRUE, any.missing = FALSE, min.len = 1))
        ),
        end = p_uty(
          tags = c("train", "predict"),
          custom_check = crate(function(x) check_numeric(x, finite = TRUE, any.missing = FALSE, min.len = 1))
        )
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
      begin = pars$begin
      end = pars$end
      assert_true(length(begin) == length(end))
      if (!is.null(begin) && !is.null(end)) {
        assert_true(all(begin < end))
      }

      for (j in seq_along(dt)) {
        set(dt, j = j, value = invoke(tf::tf_zoom, f = dt[[j]], .args = pars))
      }
      dt
    }
  )
)

#' @include zzz.R
register_po("fda.zoom", PipeOpFDAZoom)
