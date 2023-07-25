#' @title Diffusion Tensor Imaging (DTI) Regression Task
#'
#' @name mlr_tasks_dti
#' @format [R6::R6Class] inheriting from [TaskRegr].
#'
#' @description
#' This dataset contains two functional covariates and three scalar covariate. The goal is
#' to predict the PASAT score. `pasat` represents the PASAT score at each vist.
#' `subject_id` represents the subject ID. `cca` represents the fractional anisotropy tract profiles from the corpus
#' callosum. `sex` indicates subject's sex. `rcst` represents the fractional anisotropy tract profiles from the right
#' corticospinal tract. `case` indicates wether the subject has multiple sclerosis. Rows with NAs are removed.
#'
#'
#' This is a subset of the full dataset, which is contained in the package `refund`.
#'
#' @section Construction:
#'
#' ```
#' mlr_tasks$get("dti")
#' tsk("dti")
#' ```
#' @references `r format_bib("goldsmith2011penalized")`
#'
#' Brain dataset courtesy of Gordon Kindlmann at the Scientific Computing and Imaging Institute, University of Utah,
#' and Andrew Alexander, W. M. Keck Laboratory for Functional Brain Imaging and Behavior, University of
#' Wisconsin-Madison.
#'
NULL

load_task_dti = function(id = "dti") {
  b = as_data_backend(load_dataset("dti", package = "mlr3fda"))

  task = TaskRegr$new(
    id = id,
    backend = b,
    target = "pasat",
    label = "Diffusion Tensor Imaging (DTI)",
  )
  b$hash = task$man = "mlr3::mlr_tasks_dti"
  task$col_roles$group = "subject_id"
  task$col_roles$feature = setdiff(task$col_roles$feature, "subject_id")
  task
}

#' @include zzz.R
register_task("dti", load_task_dti)
