#' @title Register (Align) Functional Columns
#'
#' @name mlr_pipeops_fda.register
#'
#' @description
#' Aligns functional features by estimating warping functions against a template using [tf::tf_register()].
#' Registration reduces phase (horizontal) variability while preserving amplitude (vertical) variability,
#' which is useful when curves share a common shape but differ in the timing of their features.
#'
#' During training, a template is learned for each functional column (either estimated iteratively from the
#' data or supplied via `args`). The template is stored as part of the `$state` and reused at predict time
#' so that new observations are aligned to the same reference as the training data.
#'
#' Supported methods are `"srvf"`, `"cc"`, and `"affine"`. The `"landmark"` method from [tf::tf_register()]
#' is not supported because it requires per-observation landmark positions for both training and prediction
#' data, which does not fit a stateful preprocessing step. For landmark registration, use [tf::tf_register()]
#' directly and feed the aligned data into the task.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreproc`][mlr3pipelines::PipeOpTaskPreproc],
#' as well as the following parameters:
#' * `method` :: `character(1)`\cr
#'   Registration method. One of:
#'   * `"srvf"`: elastic registration using the Square Root Velocity Framework via [fdasrvf::time_warping()].
#'     Requires regular grids and the \CRANpkg{fdasrvf} package. Default template is the Karcher mean.
#'   * `"cc"`: continuous-criterion registration with monotone spline warps. Requires regular grids.
#'     Default template is the arithmetic mean.
#'   * `"affine"`: affine (shift and/or scale) registration with warps of the form \eqn{h(t) = a \cdot t + b}.
#'     Supports regular and irregular grids. Default template is the arithmetic mean.
#'
#'   Default is `"srvf"`.
#' * `args` :: named `list()`\cr
#'   Method-specific arguments passed to [tf::tf_register()] via `...`. See the help page of
#'   [tf::tf_estimate_warps()] for valid arguments (e.g. `lambda` / `penalty_method` for `"srvf"`;
#'   `nbasis`, `lambda`, `crit`, `conv`, `iterlim` for `"cc"`; `type`, `shift_range`, `scale_range`
#'   for `"affine"`). An optional `template` entry is honored at training time and stored in the state.
#' * `max_iter` :: `integer(1)`\cr
#'   Maximum number of Procrustes-style template refinement iterations during training. Default is `3`.
#'   Ignored at predict time because the stored template is used directly.
#' * `tol` :: `numeric(1)`\cr
#'   Convergence tolerance for template refinement during training. Default is `0.01`.
#'
#' @section State:
#' `$state$templates` contains the learned template (as a length-1 `tf` vector) for each functional column.
#'
#' @export
#' @examples
#' set.seed(1)
#' task = tsk("fuel")
#' po_reg = po("fda.register", method = "affine", args = list(type = "shift_scale"))
#' task_reg = po_reg$train(list(task))[[1L]]
#' task_reg$data(cols = c("NIR", "UVVIS"))
PipeOpFDARegister = R6Class(
  "PipeOpFDARegister",
  inherit = PipeOpTaskPreproc,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.register"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.register", param_vals = list()) {
      param_set = ps(
        method = p_fct(default = "srvf", c("srvf", "cc", "affine"), tags = c("train", "predict")),
        args = p_uty(
          tags = c("train", "predict", "required"),
          custom_check = crate(function(x) check_list(x, names = "unique"))
        ),
        max_iter = p_int(1L, default = 3L, tags = "train"),
        tol = p_dbl(default = 1e-2, lower = 0, tags = "train")
      )
      param_set$set_values(args = list())

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
    .train_dt = function(dt, levels, target) {
      pars = self$param_set$get_values(tags = "train")
      args = c(remove_named(pars, "args"), pars$args)
      templates = vector("list", length(dt))
      names(templates) = names(dt)
      for (j in names(dt)) {
        reg = invoke(tf::tf_register, x = dt[[j]], store_x = FALSE, .args = args)
        templates[[j]] = tf::tf_template(reg)
        set(dt, j = j, value = tf::tf_aligned(reg))
      }
      self$state = list(templates = templates)
      dt
    },

    .predict_dt = function(dt, levels) {
      pars = self$param_set$get_values(tags = "predict")
      args = c(remove_named(pars, "args"), pars$args)
      templates = self$state$templates
      for (j in names(dt)) {
        args$template = templates[[j]]
        reg = invoke(tf::tf_register, x = dt[[j]], store_x = FALSE, .args = args)
        set(dt, j = j, value = tf::tf_aligned(reg))
      }
      dt
    }
  )
)

#' @include zzz.R
register_po("fda.register", PipeOpFDARegister)
