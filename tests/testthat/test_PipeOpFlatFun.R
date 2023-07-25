test_that("PipeOpFlatFun works", {
  task = tsk("fuel")
  pop = PipeOpFlatFun$new()
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

  # does not touch irreg
  dat = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob"),
    arg = c(1, 7, 2, 3, 5),
    value = c(1, 2, 3, 4, 5)
  )
  f = tf::tfd(dat, id = "id", arg = "arg", value = "value")
  y = c(1, 2)
  dat = data.table(f = f, y = y)
  task = as_task_regr(dat, target = "y")
  task_flat = pop$train(list(task))[[1L]]
  expect_set_equal(task$feature_names, task_flat$feature_names)

  # name clashes
  dat = tsk("fuel")$select("NIR")$data(1)
  dat$NIR_1 = 1
  task = as_task_regr(dat, target = "heatan")

  pop$train(list(task))

})
