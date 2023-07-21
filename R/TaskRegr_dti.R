#' @title Diffusion Tensor Imaging (DTI) Regression Task
#'
#' @name mlr_tasks_dti
#' @format [R6::R6Class] inheriting from [TaskRegr].
#'
#' @description
#' This dataset contains two functional covariates and three scalar covariate. The goal is
#' to predict the PASAT score.
#'
#' This is a subset of the full dataset, which is contained in the package `refund`.
#'
#' @section Construction:
#'
#' ```
#' mlr_tasks$get("dti")
#' tsk("dti")
#' ```
#' @references `r format_bib("goldsmith2011penalized") `
#'
NULL

load_task_fuel = function(id = "dti") {
  b = as_data_backend(load_dataset("dti", package = "mlr3fda"))

  task = TaskRegr$new(
    id = id,
    backend = b,
    target = "pasat",
    label = "Diffusion Tensor Imaging (DTI)",
  )

  b$hash = task$man = "mlr3::mlr_tasks_dti"
  task
}
