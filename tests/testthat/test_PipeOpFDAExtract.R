test_that("PipeOpFDAExtract - basic properties", {
  pop = po("fda.extract")
  expect_pipeop(pop)
  expect_equal(pop$id, "fda.extract")
})

test_that("PipeOpFDAExtract works", {
  # tf_reg works
  dt = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob", "Bob"),
    arg = rep(1:3, 2L),
    value = 1:6
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  y = 1:2
  dt = data.table(f = f, y = y)
  task = as_task_regr(dt, target = "y")

  po_fmean = po("fda.extract", features = "mean", drop = TRUE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_equal(fmean, c(2, 5))

  # multiple functions work
  pop = po("fda.extract", features = c("mean", "median", "var"), drop = TRUE)
  task_pop = pop$train(list(task))[[1L]]
  expect = data.table(y = 1:2, f_mean = c(2, 5), f_median = c(2, 5), f_var = c(1, 1))
  expect_equal(task_pop$data(), expect)

  pop = po("fda.extract", features = list("mean", "median", "var"), drop = TRUE)
  task_pop = pop$train(list(task))[[1L]]
  expect = data.table(y = 1:2, f_mean = c(2, 5), f_median = c(2, 5), f_var = c(1, 1))
  expect_equal(task_pop$data(), expect)

  # custom function works
  custom = function(arg, value) {
    mean(value, na.rm = TRUE)
  }
  pop = po("fda.extract", features = list("mean", custom = custom), drop = TRUE)
  task_pop = pop$train(list(task))[[1L]]
  expect = data.table(y = 1:2, f_mean = c(2, 5), f_custom = c(2, 5))
  expect_equal(task_pop$data(), expect)

  # return NA if not in interval
  po_fmean = po("fda.extract", features = "mean", drop = TRUE, left = 100, right = 200)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_equal(fmean, rep(NA_real_, 2L))

  pop = po("fda.extract", features = c("mean", "median", "min"), drop = TRUE, left = 100, right = 200)
  task_pop = pop$train(list(task))[[1L]]
  expected = data.table(
    y = 1:2, f_mean = rep(NA_real_, 2L), f_median = rep(NA_real_, 2L), f_min = rep(NA_real_, 2L)
  )
  expect_equal(task_pop$data(), expected)

  # tf_irreg works
  dt = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob"),
    arg = c(1, 7, 2, 3, 5),
    value = c(1, 2, 3, 4, 5)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  y = c(1, 2)
  dt = data.table(f = f, y = y)
  task = as_task_regr(dt, target = "y")

  po_fmean = po("fda.extract", features = list("mean", "median", custom = custom), drop = TRUE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_equal(fmean, c(2, 4.5))

  po_fmean = po("fda.extract", features = "mean", drop = TRUE, left = 1, right = 3)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_equal(fmean, c(2, 4))

  # return NA if not in interval
  po_fmean = po("fda.extract", features = list("mean"), drop = TRUE, left = 100, right = 200)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_equal(fmean, rep(NA_real_, 2L))

  # drop works
  po_fmean = po("fda.extract", features = list("mean"), drop = FALSE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  expect_set_equal(task_fmean$feature_names, c("f", "f_mean"))

  po_fmean = po("fda.extract", features = list("mean"), drop = TRUE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  expect_set_equal(task_fmean$feature_names, "f_mean")

  # affect_columns works
  po_fmean = po("fda.extract", features = list("mean"), drop = TRUE, affect_columns = selector_name("abc"))
  task_fmean = po_fmean$train(list(task))[[1L]]
  expect_set_equal(task_fmean$feature_names, "f")
})

test_that("PipeOpFDAExtract works (simple test) for all features", {
  task = tsk("fuel")
  pop = po("fda.extract")
  features = list("mean", "min", "max", "slope", "median")
  pop$param_set$values$features = features
  expect_no_error(pop$train(list(task)))
})

test_that("PipeOpFDAExtract input validation works", {
  # features not a list or character
  expect_error(po("fda.extract", features = 2L))
  # wrong features
  expect_error(po("fda.extract", features = list("mean", "fmean")))
  expect_error(po("fda.extract", features = c("mean", "fmean")))
  # duplicate features
  expect_error(po("fda.extract", features = list("mean", "mean")))
  # value other than function or string
  expect_error(po("fda.extract", features = list("mean", 2L)))
  # wrong params for feature function
  expect_error(po("fda.extract", features = list(custom = function(arg) mean(arg, na.rm = TRUE))))
  expect_error(po("fda.extract", features = list(custom = function(value) mean(value, na.rm = TRUE))))
  expect_error(po("fda.extract", features = list(custom = function(x, y) sum(x, y))))
  # missing name for custom function
  expect_error(po("fda.extract", features = list(function(arg, value) mean(value, na.rm = TRUE))))
})

test_that("PipeOpFDAExtract works with name clashes", {
  dt = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob"),
    arg = c(1, 7, 2, 3, 5),
    value = c(1, 2, 3, 4, 5)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  y = c(1, 2)
  dt = data.table(f = f, y = y)
  dt$f_mean = c(-1, -1)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.extract", features = list("mean"), drop = FALSE)
  taskout = pop$train(pop$train(list(task)))[[1L]]
  expect_permutation(taskout$feature_names, c("f", "f_mean", "f_mean_1", "f_mean_2"))
})
