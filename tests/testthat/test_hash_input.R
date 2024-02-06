test_that("hash input for tfd vectors", {
  # this tests that the hash of the DataBackendDataTable is not influenced by bagge of the evaluator attribute
  # of tfd vectors
  x_reg = tsk("fuel")$data(cols = "NIR")[[1]][1:5]
  e_reg = attr(x_reg, "evaluator")
  x_irreg = tsk("dti")$data(cols = "cca")[[1]][1:5]
  e_irreg = attr(x_irreg, "evaluator")

  e_reg1 = e_reg
  environment(e_reg1) = new.env()
  x_reg1 = x_reg
  attr(x_reg1, "evaluator") = e_reg1

  d1 = as_data_backend(data.table(
    y = 1:5,
    x_reg = x_reg1,
    x_irreg = x_irreg
  ))

  e_irreg1 = e_irreg
  environment(e_irreg1) = new.env()
  x_irreg1 = x_irreg
  attr(x_irreg1, "evaluator") = e_irreg1

  d2 = as_data_backend(data.table(
    y = 1:5,
    x_reg = x_reg,
    x_irreg = x_irreg1
  ))

  d3 = as_data_backend(data.table(
    y = 1:5,
    x_reg = x_reg,
    x_irreg = x_irreg
  ))

  expect_equal(d1$hash, d2$hash)
  expect_equal(d2$hash, d3$hash)
})
