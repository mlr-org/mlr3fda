test_that("PipeOpFDAIntegrate - basic properties", {
  pop = po("fda.integrate")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.integrate")
})

test_that("PipeOpFDAIntegrate works on regular data", {
  task = tsk("fuel")
  pop = po("fda.integrate")
  task_integrate = train_pipeop(pop, list(task))[[1L]]
  new_data = task_integrate$data()
  expect_task(task_integrate)
  expect_identical(task_integrate$n_features, task$n_features)
  expect_subset(c("NIR_integral", "UVVIS_integral"), task_integrate$feature_names)
  expect_numeric(new_data$NIR_integral, finite = TRUE, any.missing = FALSE)
  expect_numeric(new_data$UVVIS_integral, finite = TRUE, any.missing = FALSE)
  expect_identical(new_data, predict_pipeop(pop, list(task))[[1L]]$data())
})

test_that("PipeOpFDAIntegrate works on irregular data", {
  task = tsk("dti")
  pop = po("fda.integrate")
  new_data = train_pipeop(pop, list(task))[[1L]]$data()
  expect_identical(nrow(new_data), task$nrow)
  expect_numeric(new_data$cca_integral)
  expect_numeric(new_data$rcst_integral)
})

test_that("PipeOpFDAIntegrate window changes the result", {
  task = tsk("fuel")
  full = train_pipeop(po("fda.integrate"), list(task))[[1L]]$data()$NIR_integral
  windowed = train_pipeop(po("fda.integrate", lower = 50, upper = 100), list(task))[[1L]]$data()$NIR_integral
  expect_false(isTRUE(all.equal(full, windowed)))
})
