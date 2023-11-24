if (requireNamespace("testthat", quietly = TRUE)) {
  library("checkmate")
  library("testthat")
  library("mlr3fda")
  library("tf")
  test_check("mlr3fda")
}
