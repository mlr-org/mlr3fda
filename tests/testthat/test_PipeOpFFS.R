test_that("PipeOpFFS works", {
  # tf_reg works
  dat = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob", "Bob"),
    arg = rep(1:3, 2),
    value = 1:6
  )
  f = tf::tfd(dat, id = "id", arg = "arg", value = "value")
  y = c(1, 2)
  dat = data.table(f = f, y = y)
  task = as_task_regr(dat, target = "y")

  po_fmean = po("ffs", features = "mean", drop = TRUE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_equal(fmean, c(2, 5))

  # multiple functions work
  pop = po("ffs", features = c("mean", "median", "var"), drop = TRUE)
  task_pop = pop$train(list(task))[[1L]]
  expect = data.table(y = 1:2, f_mean = c(2, 5), f_median = c(2, 5), f_var = c(1, 1))
  expect_equal(task_pop$data(), expect)

  pop = po("ffs", features = list("mean", "median", "var"), drop = TRUE)
  task_pop = pop$train(list(task))[[1L]]
  expect = data.table(y = 1:2, f_mean = c(2, 5), f_median = c(2, 5), f_var = c(1, 1))
  expect_equal(task_pop$data(), expect)

  # custom function works
  custom = function(arg, value) {
    mean(value, na.rm = TRUE)
  }
  pop = po("ffs", features = list("mean", custom = custom), drop = TRUE)
  task_pop = pop$train(list(task))[[1L]]
  expect = data.table(y = 1:2, f_mean = c(2, 5), f_custom = c(2, 5))
  expect_equal(task_pop$data(), expect)

  # return NA if not in interval
  po_fmean = po("ffs", features = "mean", drop = TRUE, left = 100, right = 200)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_equal(fmean, rep(NA_real_, 2))

  pop = po("ffs", features = c("mean", "median", "min"), drop = TRUE, left = 100, right = 200)
  task_pop = pop$train(list(task))[[1L]]
  expected = data.table(
    y = 1:2, f_mean = rep(NA_real_, 2), f_median = rep(NA_real_, 2), f_min = rep(NA_real_, 2)
  )
  expect_equal(task_pop$data(), expected)

  # tf_irreg works
  dat = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob"),
    arg = c(1, 7, 2, 3, 5),
    value = c(1, 2, 3, 4, 5)
  )
  f = tf::tfd(dat, id = "id", arg = "arg", value = "value")
  y = c(1, 2)
  dat = data.table(f = f, y = y)
  task = as_task_regr(dat, target = "y")

  po_fmean = po("ffs", features = list("mean", "median", custom = custom), drop = TRUE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_equal(fmean, c(2, 4.5))

  po_fmean = po("ffs", features = "mean", drop = TRUE, left = 1, right = 3)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_equal(fmean, c(2, 4))

  # return NA if not in interval
  po_fmean = po("ffs", features = list("mean"), drop = TRUE, left = 100, right = 200)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_equal(fmean, rep(NA_real_, 2))

  # drop works
  po_fmean = po("ffs", features = list("mean"), drop = FALSE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  expect_set_equal(task_fmean$feature_names, c("f", "f_mean"))

  po_fmean = po("ffs", features = list("mean"), drop = TRUE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  expect_set_equal(task_fmean$feature_names, "f_mean")

  # affect_columns works
  po_fmean = po("ffs", features = list("mean"), drop = TRUE, affect_columns = selector_name("abc"))
  task_fmean = po_fmean$train(list(task))[[1L]]
  expect_set_equal(task_fmean$feature_names, "f")
})

test_that("PipeOpFFS works (simple test) for all features", {
  task = tsk("fuel")
  pop = po("ffs")
  features = list("mean", "min", "max", "slope", "median")
  pop$param_set$values$features = features
  expect_no_error(pop$train(list(task)))
})

test_that("PipeOpFFS input validation works", {
  # features not a list or character
  expect_error(po("ffs", features = 2L))
  # wrong features
  expect_error(po("ffs", features = list("mean", "fmean")))
  expect_error(po("ffs", features = c("mean", "fmean")))
  # duplicate features
  expect_error(po("ffs", features = list("mean", "mean")))
  # value other than function or string
  expect_error(po("ffs", features = list("mean", 2L)))
  # wrong params for feature function
  expect_error(po("ffs", features = list(custom = function(arg) mean(arg, na.rm = TRUE))))
  expect_error(po("ffs", features = list(custom = function(value) mean(value, na.rm = TRUE))))
  expect_error(po("ffs", features = list(custom = function(x, y) sum(x, y))))
  # missing name for custom function
  expect_error(po("ffs", features = list(function(arg, value) mean(value, na.rm = TRUE))))
})

test_that("PipeOpFFS works with name clashes", {
  dat = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob"),
    arg = c(1, 7, 2, 3, 5),
    value = c(1, 2, 3, 4, 5)
  )
  f = tf::tfd(dat, id = "id", arg = "arg", value = "value")
  y = c(1, 2)
  dat = data.table(f = f, y = y)
  dat$f_mean = c(-1, -1)
  task = as_task_regr(dat, target = "y")

  pop = po("ffs", features = list("mean"))
  expect_warning(
    pop$train(list(task))[[1L]],
    regexp = "Unique names for"
  )
})

test_that("ffind works", {
  expect_equal(ffind(1:5, 2, 4), c(2, 4))
  x = 0:10 * 3
  expect_equal(ffind(x, 9, 25), c(4, 9))
  expect_equal(ffind(x, 9.5, 24.5), c(5, 9))
  expect_equal(ffind(x, 9.5, 21.5), c(5, 8))
  # non-integer
  x = c(1.2, 2.3, 3.4, 4.5)
  expect_equal(ffind(x, 2.5, 4), c(3, 3))
  # min/max
  x = c(2, 3, 4, 4)
  expect_equal(ffind(x), c(1, 4))
  expect_equal(ffind(1:10, -1, 11), c(1, 10))
  # negative numbers
  x = c(-5, -3, -1, 1, 3)
  expect_equal(ffind(x, -3, 1), c(2, 4))
  # not in interval
  expect_equal(ffind(2:5, 6, 10), c(NA_integer_, NA_integer_))
  expect_equal(ffind(2:5, 1, 1), c(NA_integer_, NA_integer_))
  # single element
  expect_equal(ffind(5, 5, 5), c(1, 1))
  expect_equal(ffind(5, 4, 6), c(1, 1))
  expect_equal(ffind(5, 6, 7), c(NA_integer_, NA_integer_))
  # NA values
  x = c(2, NA, 4, 5)
  expect_equal(ffind(x, 2, 5), c(1, 4))
  # large vector
  x = 1:1e6
  expect_equal(ffind(x, 1e5, 1e6), c(1e5, 1e6))
})
