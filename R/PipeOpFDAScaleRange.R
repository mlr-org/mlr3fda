#' @title Linearly Transform the Domain of Functional Data
#'
#' @name mlr_pipeops_fda.scalerange
#'
#' @description
#' Linearly transform the domain of functional data so they are between `lower` and `upper`.
#' The formula for this is \eqn{x' = offset + x * scale},
#' where \eqn{scale} is \eqn{(upper - lower) / (max(x) - min(x))} and
#' \eqn{offset} is \eqn{-min(x) * scale + lower}. The same transformation is applied during training and prediction.
#'
#' @section State:
#' The `$state` is a named `list` with the `$state` elements inherited from
#' [`PipeOpTaskPreproc`][mlr3pipelines::PipeOpTaskPreproc], as well as:
#' * `trafos` :: named `list()`\cr
#'   For each functional column, a `list()` with the training `domain`,
#'   and the `scale` and `offset` of the transformation.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreproc`][mlr3pipelines::PipeOpTaskPreproc],
#' as well as the following parameters:
#' * `lower` :: `numeric(1)`\cr
#'   Target value of smallest item of input data. Initialized to `0`.
#' * `upper` :: `numeric(1)`\cr
#'   Target value of greatest item of input data. Initialized to `1`.
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' po_scale = po("fda.scalerange", lower = -1, upper = 1)
#' task_scale = po_scale$train(list(task))[[1L]]
#' task_scale$data()
PipeOpFDAScaleRange = R6Class(
  "PipeOpFDAScaleRange",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.scalerange"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.scalerange", param_vals = list()) {
      param_set = ps(
        lower = p_dbl(init = 0, tags = c("train", "required")),
        upper = p_dbl(init = 1, tags = c("train", "required"))
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
    .get_state_dt = function(dt, levels, target) {
      pars = self$param_set$get_values(tags = "train")
      if (pars$lower >= pars$upper) {
        error_config("'lower' must be smaller than 'upper'.")
      }

      trafos = map(dt, function(x) {
        domain = tf::tf_domain(x)
        scale = (pars$upper - pars$lower) / (domain[2L] - domain[1L])
        offset = -domain[1L] * scale + pars$lower
        list(domain = domain, scale = scale, offset = offset)
      })
      list(trafos = trafos)
    },

    .transform_dt = function(dt, levels) {
      trafos = self$state$trafos
      for (j in names(dt)) {
        x = dt[[j]]
        trafo = trafos[[j]]
        if (!all(trafo$domain == tf::tf_domain(x))) {
          error_input("Domain of new data does not match the domain of the training data.")
        }
        set(dt, j = j, value = rescale_domain(x, trafo$scale, trafo$offset))
      }
      dt
    }
  )
)

rescale_domain = function(x, scale, offset) {
  args = tf::tf_arg(x)
  new_args = if (tf::is_reg(x)) offset + args * scale else map(args, \(arg) offset + arg * scale)
  invoke(
    tf::tfd,
    data = tf::tf_evaluations(x),
    arg = new_args,
    domain = offset + tf::tf_domain(x) * scale,
    .args = list(evaluator = attr(x, "evaluator_name"))
  )
}

#' @include zzz.R
register_po("fda.scalerange", PipeOpFDAScaleRange)
