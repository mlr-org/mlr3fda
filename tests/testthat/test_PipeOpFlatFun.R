test_that("PipeOpFlatFun works", {
  task = tsk("fuel")
  pop = po("flatfun")
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

test_that("PipeOpFlatFun works with name clashes", {
  dt = tsk("fuel")$select("NIR")$data(1)
  dt$NIR_1 = 1
  task = as_task_regr(dt, target = "heatan")
  pop = po("flatfun")
  expect_warning(
    pop$train(list(task)),
    regexp = "Unique names for"
  )
})

test_that("PipeOpFlatFun works without interpolation", {
  # reg works without interpolation
  dt = data.table(
    id = rep(1:2, each = 5),
    arg = rep(1:5, 2),
    value = c(1, NA, 5, 5, 7, 3, 5, 10, NA, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("flatfun", interpolate = FALSE)
  task_flat = pop$train(list(task))[[1L]]
  expected = data.table(
    y = 1:2, f_1 = c(1, 3), f_2 = c(NA, 5), f_3 = c(5, 10), f_4 = c(5, NA), f_5 = c(7, 12)
  )
  expect_set_equal(c("f_1", "f_2", "f_3", "f_4", "f_5"), task_flat$feature_names)
  expect_equal(task_flat$data(), expected)

  # irreg works with interpolation
  dt = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob"),
    arg = c(1, 7, 2, 3, 5),
    value = 1:5
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = c(1, 2), f = f)
  task = as_task_regr(dt, target = "y")
  # pop = po("flatfun", grid = 3:4)
  pop = po("flatfun", grid = "intersect")
  task_flat = pop$train(list(task))[[1L]]
  expected = data.table(
    y = 1:2, f_1 = c(1, NA), f_2 = c(3, NA), f_3 = c(2.8, 4), f_4 = c(2.4, 5), f_5 = c(2, NA)
  )
  expect_set_equal(c("f_1", "f_2", "f_3", "f_4", "f_5"), task_flat$feature_names)
  expect_equal(task_flat$data(), expected)
})

test_that("PipeOpFlatFun works with interpolation", {
  # reg works with interpolation
  dt = data.table(
    id = rep(1:2, each = 5),
    arg = rep(1:5, 2),
    value = c(1, NA, 5, 5, 7, 3, 5, 10, NA, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("flatfun", interpolate = TRUE)
  task_flat = pop$train(list(task))[[1L]]
  expected = data.table(
    y = 1:2, f_1 = c(1, 3), f_2 = c(3, 5), f_3 = c(5, 10), f_4 = c(5, 11), f_5 = c(7, 12)
  )
  expect_set_equal(c("f_1", "f_2", "f_3", "f_4", "f_5"), task_flat$feature_names)
  expect_equal(task_flat$data(), expected)

  # irreg works with interpolation
  dt = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob"),
    arg = c(1, 7, 2, 3, 5),
    value = 1:5
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = c(1, 2), f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("flatfun", interpolate = TRUE)
  task_flat = pop$train(list(task))[[1L]]
  expected = data.table(
    y = 1:2, f_1 = c(1, NA), f_2 = c(3, NA), f_3 = c(2.8, 4), f_4 = c(2.4, 5), f_5 = c(2, NA)
  )
  expect_set_equal(c("f_1", "f_2", "f_3", "f_4", "f_5"), task_flat$feature_names)
  expect_equal(task_flat$data(), expected)
})
