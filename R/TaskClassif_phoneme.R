#' @title Phoneme Classification Task
#'
#' @name mlr_tasks_phoneme
#' @format [R6::R6Class] inheriting from [TaskClassif].
#'
#' @description
#' The task contains a single functional covariate and 5 equally big classes (aa, ao, dcl, iy, sh).
#' The aim is to predict the class of the phoneme in the functional, which is a
#' log-periodogram.\cr
#' This is a subset of the full dataset, which is contained in the package `fda.usc`.
#'
#' @templateVar id phoneme
#' @template task
#'
#' @references `r format_bib("ferraty2003curves")`
#'
#' @template seealso_task
NULL

load_task_phoneme = function(id = "phoneme") {
  phoneme = load_dataset("phoneme", package = "mlr3fda")
  phoneme = data.table(
    class = phoneme$classlearn,
    X = tf::tfd(as.matrix(phoneme[, -151L]))
  )
  b = as_data_backend(phoneme)

  task = TaskClassif$new(
    id = id,
    backend = b,
    target = "class",
    label = "Phoneme Curves"
  )
  b$hash = task$man = "mlr3fda::mlr_tasks_phoneme"
  task
}

#' @include zzz.R
register_task("phoneme", load_task_phoneme)
