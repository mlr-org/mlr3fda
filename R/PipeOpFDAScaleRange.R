#' @title Linearly Transform the Domain of Functional Data.
#' @name mlr_pipeops_fda.scalerange
#'
#' @description
#' Linearly transform the domain of functional data so they are between `lower` and `upper`.
#' The formula for this is \eqn{x' = offset + x * scale},
#' where \eqn{scale} is \eqn{(upper - lower) / (max(x) - min(x))} and
#' \eqn{offset} is \eqn{-min(x) * scale + lower}. The same transformation is applied during training and prediction.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreproc`][mlr3pipelines::PipeOpTaskPreproc],
#' as well as the following parameters:
#' * `lower` :: `numeric(1)` \cr
#' Target value of smallest item of input data. Initialized to `0`.
#' * `uppper` :: `numeric(1)` \cr
#' Target value of greatest item of input data. Initialized to `1`.
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' po_scale = po("fda.scalerange", lower = -1, upper = 1)
#' task_scale = po_scale$train(list(task))[[1L]]
#' task_scale$data()
PipeOpFDAScaleRange = R6Class("PipeOpFDAScaleRange",
  inherit = PipeOpTaskPreproc,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.scalerange"`.
    #' @param param_vals (named `list`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.scalerange", param_vals = list()) {
      param_set = ps(
        lower = p_dbl(tags = c("required", "train")),
        upper = p_dbl(tags = c("required", "train"))
      )
      param_set$set_values(lower = 0, upper = 1)

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3fda", "mlr3pipelines", "tf"),
        feature_types = c("tfd_irreg", "tfd_reg"),
        tags = "fda"
      )
    }
  ),
  private = list(
    .train_dt = function(dt, levels, target) {
      pars = self$param_set$get_values(tags = "train")

      imap_dtc(dt, function(x, nm) {
        domain = tf::tf_domain(x)
        scale = (pars$upper - pars$lower) / (domain[2L] - domain[1L])
        offset = -domain[1L] * scale + pars$lower
        self$state[[nm]] = list(domain = domain, scale = scale, offset = offset)

        args = tf::tf_arg(x)
        if (tf::is_reg(x)) {
          new_args = offset + args * scale
        } else {
          new_args = map(args, function(arg) offset + arg * scale)
        }
        invoke(tf::tfd, data = tf::tf_evaluations(x), arg = new_args)
      })
    },

    .predict_dt = function(dt, levels) {
      imap_dtc(dt, function(x, nm) {
        trafo = self$state[[nm]]
        if (!all(trafo$domain == tf::tf_domain(x))) {
          stopf("Domain of new data does not match the domain of the training data.")
        }
        args = tf::tf_arg(x)
        if (tf::is_reg(x)) {
          new_args = trafo$offset + args * trafo$scale
        } else {
          new_args = map(args, function(arg) trafo$offset + arg * trafo$scale)
        }
        invoke(tf::tfd, data = tf::tf_evaluations(x), arg = new_args)
      })
    }
  )
)

#' @include zzz.R
register_po("fda.scalerange", PipeOpFDAScaleRange)
