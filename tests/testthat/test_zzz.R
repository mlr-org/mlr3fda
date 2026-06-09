test_that("as.data.table(mlr_pipeops) works with fda PipeOps registered", {
  dt = as.data.table(mlr_pipeops)
  fda_keys = names(mlr3fda_pipeops)
  fda_rows = dt[get("key") %chin% fda_keys]

  expect_data_table(fda_rows, nrows = length(fda_keys))
  expect_false(anyNA(fda_rows$label))
})
