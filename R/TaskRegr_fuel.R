#' @title Fuel Regression Task
#'
#' @name mlr_tasks_fuel
#' @format [R6::R6Class] inheriting from [mlr3::TaskRegr].
#'
#' @description
#' This dataset contains two functional covariates and one scalar covariate. The goal is
#' to predict the heat value of some fuel based on the ultraviolet radiation spectrum and
#' infrared ray radiation and one scalar column called h2o.
#'
#' This is a subset of the full dataset, which is contained in the package `FDboost`.
#'
#' @templateVar id fuel
#' @template task
#'
#' @references `r format_bib("brockhaus2015functional") `
#'
#' @template seealso_task
NULL

load_task_fuel = function(id = "fuel") {
  fuel = load_dataset("fuel", package = "mlr3fda")
  fuel = data.table(
    heatan = fuel$heatan,
    h20 = fuel$h20,
    UVVIS = tf::tfd(fuel$UVVIS),
    NIR = tf::tfd(fuel$NIR)
  )
  b = as_data_backend(fuel)

  task = TaskRegr$new(
    id = id,
    backend = b,
    target = "heatan",
    label = "Spectral Data of Fossil Fuels",
  )

  b$hash = task$man = "mlr3fda::mlr_tasks_fuel"
  task
}

#' @include zzz.R
register_task("fuel", load_task_fuel)
