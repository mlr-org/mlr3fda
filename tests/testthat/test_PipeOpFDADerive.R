test_that("PipeOpFDADerive - basic properties", {
  pop = po("fda.derive")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.derive")
  expect_identical(pop$param_set$values$order, 1L)
})

test_that("PipeOpFDADerive works on regular data", {
  task = tsk("fuel")
  pop = po("fda.derive")
  task_deriv = train_pipeop(pop, list(task))[[1L]]
  new_data = task_deriv$data()
  expect_task(task_deriv)
  expect_identical(task_deriv$n_features, task$n_features)
  expect_class(new_data$NIR, "tfd_reg")
  expect_class(new_data$UVVIS, "tfd_reg")
  expect_identical(new_data, predict_pipeop(pop, list(task))[[1L]]$data())
})

test_that("PipeOpFDADerive second-order derivative", {
  task = tsk("fuel")
  pop = po("fda.derive", order = 2L)
  new_data = train_pipeop(pop, list(task))[[1L]]$data()
  expect_class(new_data$NIR, "tfd_reg")
  expect_class(new_data$UVVIS, "tfd_reg")
})

test_that("PipeOpFDADerive works on irregular data", {
  task = tsk("dti")
  pop = po("fda.derive")
  new_data = train_pipeop(pop, list(task))[[1L]]$data()
  expect_class(new_data$cca, "tfd_irreg")
  expect_class(new_data$rcst, "tfd_irreg")
})

test_that("PipeOpFDADerive validates order", {
  expect_error(po("fda.derive", order = 0L))
  expect_error(po("fda.derive", order = -1L))
})
