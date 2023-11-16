test_that("PipeOpfda.flatten works", {
  task = tsk("fuel")
  pop = po("fda.flatten")
  x = pop$train(list(task))[[1L]]
  expected_features = c(
    "h20",
    paste0("UVVIS_", 1:134),
    paste0("NIR_", 1:231)
  )
  expect_set_equal(x$feature_names, expected_features)

  pop$param_set$values$affect_columns = selector_name("UVVIS")
  x = pop$train(list(task))[[1L]]
  expected_features = c(
    "h20",
    paste0("UVVIS_", 1:134),
    "NIR"
  )
  expect_set_equal(x$feature_names, expected_features)

  pop$param_set$values$affect_columns = selector_name("..xyz")
  x = pop$train(list(task))[[1L]]
  expected_features = c(
    "h20",
    "UVVIS",
    "NIR"
  )
  expect_set_equal(x$feature_names, expected_features)
})

test_that("PipeOpfda.flatten works with name clashes", {
  dt = tsk("fuel")$select("NIR")$data(1)
  dt$NIR_1 = 1
  task = as_task_regr(dt, target = "heatan")
  pop = po("fda.flatten")
  expect_warning(
    pop$train(list(task)),
    regexp = "Unique names for"
  )
})
