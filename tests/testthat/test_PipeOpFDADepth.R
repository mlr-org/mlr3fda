test_that("PipeOpFDADepth - basic properties", {
  pop = po("fda.depth")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.depth")
  expect_identical(pop$param_set$values$method, "MBD")
  expect_true(pop$param_set$values$na.rm)
})

test_that("PipeOpFDADepth works on regular data", {
  task = tsk("fuel")
  pop = po("fda.depth")
  task_depth = train_pipeop(pop, list(task))[[1L]]
  new_data = task_depth$data()
  expect_task(task_depth)
  expect_identical(task_depth$n_features, task$n_features)
  expect_subset(c("NIR_depth", "UVVIS_depth"), task_depth$feature_names)
  expect_numeric(new_data$NIR_depth, finite = TRUE, any.missing = FALSE)
  expect_numeric(new_data$UVVIS_depth, finite = TRUE, any.missing = FALSE)
  expect_identical(new_data, predict_pipeop(pop, list(task))[[1L]]$data())
})

test_that("PipeOpFDADepth supports all methods", {
  task = tsk("fuel")
  for (method in c("MBD", "MHI", "FM", "FSD")) {
    new_data = train_pipeop(po("fda.depth", method = method), list(task))[[1L]]$data()
    expect_numeric(new_data$NIR_depth, finite = TRUE, any.missing = FALSE)
  }
})

test_that("PipeOpFDADepth RPD is reproducible with a seed", {
  task = tsk("fuel")
  withr::local_seed(1)
  a = train_pipeop(po("fda.depth", method = "RPD"), list(task))[[1L]]$data()$NIR_depth
  withr::local_seed(1)
  b = train_pipeop(po("fda.depth", method = "RPD"), list(task))[[1L]]$data()$NIR_depth
  expect_identical(a, b)
})

test_that("PipeOpFDADepth works on irregular data with incomplete curves", {
  task = tsk("dti")
  pop = po("fda.depth")
  new_data = train_pipeop(pop, list(task))[[1L]]$data()
  expect_identical(nrow(new_data), task$nrow)
  expect_numeric(new_data$cca_depth)
  expect_numeric(new_data$rcst_depth)
  expect_gt(sum(is.na(new_data$rcst_depth)), 0)
})
