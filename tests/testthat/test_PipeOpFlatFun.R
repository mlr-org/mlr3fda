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

test_that("PipeOpFlatFun input validation works", {
  # grid is missing NULL
  expect_error(po("flatfun", grid = NULL))
  # grid has NAs
  expect_error(po("flatfun", grid = NA))
  expect_error(po("flatfun", grid = c(1, NA)))
  # grid is not union or intersect
  expect_error(po("flatfun", grid = "test"))
  # grid is not a string
  expect_error(po("flatfun", grid = c("union", "intersect")))
  # grid is not a list or string
  expect_error(po("flatfun", grid = list(1)))
})

test_that("PipeOpFlatFun works with union", {
  # tfr works
  dt = data.table(
    id = rep(1:2, each = 5),
    arg = rep(1:5, 2),
    value = c(1, 2, 5, 5, 7, 3, 5, 10, 2, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("flatfun", grid = "union")
  task_flat = pop$train(list(task))[[1L]]
  expected = data.table(
    y = 1:2, f_1 = c(1, 3), f_2 = c(2, 5), f_3 = c(5, 10), f_4 = c(5, 2), f_5 = c(7, 12)
  )
  expect_set_equal(c("f_1", "f_2", "f_3", "f_4", "f_5"), task_flat$feature_names)
  expect_equal(task_flat$data(), expected)

  # works with default
  pop = po("flatfun")
  task_flat = pop$train(list(task))[[1L]]
  expected = data.table(
    y = 1:2, f_1 = c(1, 3), f_2 = c(2, 5), f_3 = c(5, 10), f_4 = c(5, 2), f_5 = c(7, 12)
  )
  expect_set_equal(c("f_1", "f_2", "f_3", "f_4", "f_5"), task_flat$feature_names)
  expect_equal(task_flat$data(), expected)

  # tfi works with same min and max
  dt = data.table(
    id = rep(1:2, each = 5),
    arg = rep(1:5, 2),
    value = c(1, NA, 5, 5, 7, 3, 5, 10, NA, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("flatfun", grid = "union")
  task_flat = pop$train(list(task))[[1L]]
  expected = data.table(
    y = 1:2, f_1 = c(1, 3), f_2 = c(3, 5), f_3 = c(5, 10), f_4 = c(5, 11), f_5 = c(7, 12)
  )
  expect_set_equal(c("f_1", "f_2", "f_3", "f_4", "f_5"), task_flat$feature_names)
  expect_equal(task_flat$data(), expected)

  # tfi works with different min and max
  dt = data.table(
    id = c(rep(1, 3), rep(2, 6)),
    arg = c(3:5, 1:6),
    value = c(2, 5, 6, 1, 3, 4, 5, 6, 7)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("flatfun", grid = "union")
  task_flat = pop$train(list(task))[[1L]]
  expected = data.table(
    y = 1:2, f_1 = c(NA, 1), f_2 = c(NA, 3), f_3 = c(2, 4), f_4 = c(5, 5), f_5 = c(6, 6), f_6 = c(NA, 7))
  expect_set_equal(c("f_1", "f_2", "f_3", "f_4", "f_5", "f_6"), task_flat$feature_names)
  expect_equal(task_flat$data(), expected)
})

test_that("PipeOpFlatFun works with intersect", {
  # tfr works
  dt = data.table(
    id = rep(1:2, each = 5),
    arg = rep(1:5, 2),
    value = c(1, 2, 5, 5, 7, 3, 5, 10, 2, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("flatfun", grid = "intersect")
  task_flat = pop$train(list(task))[[1L]]
  expected = data.table(
    y = 1:2, f_1 = c(1, 3), f_2 = c(2, 5), f_3 = c(5, 10), f_4 = c(5, 2), f_5 = c(7, 12)
  )
  expect_set_equal(c("f_1", "f_2", "f_3", "f_4", "f_5"), task_flat$feature_names)
  expect_equal(task_flat$data(), expected)

  # tfi works with same min and max
  dt = data.table(
    id = rep(1:2, each = 5),
    arg = rep(1:5, 2),
    value = c(1, NA, 5, 5, 7, 3, 5, 10, NA, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("flatfun", grid = "intersect")
  task_flat = pop$train(list(task))[[1L]]
  expected = data.table(
    y = 1:2, f_1 = c(1, 3), f_2 = c(3, 5), f_3 = c(5, 10), f_4 = c(5, 11), f_5 = c(7, 12)
  )
  expect_set_equal(c("f_1", "f_2", "f_3", "f_4", "f_5"), task_flat$feature_names)
  expect_equal(task_flat$data(), expected)

  # tfi works with different min and max
  dt = data.table(
    id = c(rep(1, 3), rep(2, 6)),
    arg = c(3:5, 1:6),
    value = c(2, 5, 6, 1, 3, 4, 5, 6, 7)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("flatfun", grid = "intersect")
  task_flat = pop$train(list(task))[[1L]]
  expected = data.table(y = 1:2, f_1 = c(2, 4), f_2 = c(5, 5), f_3 = c(6, 6))
  expect_set_equal(c("f_1", "f_2", "f_3"), task_flat$feature_names)
  expect_equal(task_flat$data(), expected)
})
