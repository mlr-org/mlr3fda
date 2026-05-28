#' @title Functional Data Depth Features
#'
#' @name mlr_pipeops_fda.depth
#'
#' @description
#' Computes the data depth of functional features via [tf::tf_depth()].
#' Data depth measures how central each curve is relative to the others: values close to `1` indicate central curves
#' and values close to `0` indicate extreme curves.
#'
#' The depth is computed in-sample, i.e. each curve is scored relative to the other curves in the same data. The same
#' operation is applied during training and prediction.
#'
#' Irregular curves are interpolated to a common grid before the depth is computed. Curves that remain incomplete
#' after interpolation (e.g. because they only cover part of the grid) are assigned a depth of `NA`.
#'
#' @details
#' The `"MHI"` method ranks functions from lowest (`0`) to highest (`1`) instead of from most extreme to most central.
#' The `"RPD"` method relies on random projections, so set a seed (e.g. via [set.seed()]) before training for
#' reproducible results.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreprocSimple`][mlr3pipelines::PipeOpTaskPreprocSimple],
#' as well as the following parameters:
#' * `method` :: `character(1)`\cr
#'   The depth method to use. One of `"MBD"` (modified band depth, the default), `"MHI"` (modified hypograph index),
#'   `"FM"` (Fraiman-Muniz), `"FSD"` (functional spatial depth), or `"RPD"` (regularized projection depth).
#'   Initial value is `"MBD"`.
#' * `na.rm` :: `logical(1)`\cr
#'   Whether to remove missing observations before computing the depth. Initial value is `TRUE`.
#' * `u` :: `numeric(1)`\cr
#'   Quantile level for the regularization. Only used when `method` is `"RPD"`. Default is `0.01`.
#' * `n_projections` :: `integer(1)`\cr
#'   Number of projection directions. Only used when `method` is `"RPD"`. Default is `5000`.
#' * `n_projections_beta` :: `integer(1)`\cr
#'   Number of directions for estimating the regularization parameter. Only used when `method` is `"RPD"`.
#'   Default is `500`.
#'
#' @section Naming:
#' The new names generally append a `_depth` to the corresponding column name.
#' If a column was called `"x"`, the corresponding new column will be called `"x_depth"`.
#'
#' @export
#' @examples
#' task = tsk("fuel")
#' po_depth = po("fda.depth", method = "MBD")
#' task_depth = po_depth$train(list(task))[[1L]]
#' task_depth$data(cols = c("NIR_depth", "UVVIS_depth"))
PipeOpFDADepth = R6Class(
  "PipeOpFDADepth",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.depth"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fda.depth", param_vals = list()) {
      param_set = ps(
        method = p_fct(c("MBD", "MHI", "FM", "FSD", "RPD"), tags = c("train", "predict", "required")),
        na.rm = p_lgl(tags = c("train", "predict", "required")),
        u = p_dbl(0, 1, tags = c("train", "predict"), depends = quote(method == "RPD")),
        n_projections = p_int(1L, tags = c("train", "predict"), depends = quote(method == "RPD")),
        n_projections_beta = p_int(1L, tags = c("train", "predict"), depends = quote(method == "RPD"))
      )
      param_set$set_values(method = "MBD", na.rm = TRUE)

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
      method = pars$method
      pars = remove_named(pars, "method")
      setcbindlist(imap(dt, function(x, nm) {
        depth = invoke(tf::tf_depth, x = x, depth = method, .args = pars)
        if (length(depth) != length(x)) {
          # tf_depth drops curves that are incomplete after interpolation to a common grid
          complete = stats::complete.cases(as.matrix(x, interpolate = TRUE))
          depth = replace(rep(NA_real_, length(x)), complete, depth)
        }
        depth_dt = as.data.table(depth)
        setnames(depth_dt, sprintf("%s_depth", nm))
      }))
    }
  )
)

#' @include zzz.R
register_po("fda.depth", PipeOpFDADepth)
