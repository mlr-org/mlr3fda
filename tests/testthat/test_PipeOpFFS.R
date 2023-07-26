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

  po_fmean = po("ffs", feature = "mean", drop = TRUE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_true(all.equal(fmean, c(2, 5)))

  # return NA if not in interval
  po_fmean = po("ffs", feature = "mean", drop = TRUE, left = 100, right = 200)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_true(all.equal(fmean, rep(NA_real_, 2)))

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

  po_fmean = po("ffs", feature = "mean", drop = TRUE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_true(all.equal(fmean, c(2, 4.5)))

  po_fmean = po("ffs", feature = "mean", drop = TRUE, left = 1, right = 3)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_true(all.equal(fmean, c(2, 4)))

  # return NA if not in interval
  po_fmean = po("ffs", feature = "mean", drop = TRUE, left = 100, right = 200)
  task_fmean = po_fmean$train(list(task))[[1L]]
  fmean = task_fmean$data()$f_mean
  expect_true(all.equal(fmean, rep(NA_real_, 2)))

  # drop works
  po_fmean = po("ffs", feature = "mean", drop = FALSE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  expect_set_equal(task_fmean$feature_names, c("f", "f_mean"))

  po_fmean = po("ffs", feature = "mean", drop = TRUE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  expect_set_equal(task_fmean$feature_names, "f_mean")

  # affect_columns works
  po_fmean = po("ffs", feature = "mean", drop = TRUE, affect_columns = selector_name("abc"))
  task_fmean = po_fmean$train(list(task))[[1L]]
  expect_set_equal(task_fmean$feature_names, "f")
})


test_that("PipeOpFFS works (simple test) for all features", {
  task = tsk("fuel")
  pop = po("ffs")

  features = c("mean", "min", "max", "slope", "median")

  for (feature in features) {
    pop$param_set$values$feature = feature
    expect_error(pop$train(list(task)), regexp = NA)
  }

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

  pop = po("ffs", feature = "mean")
  expect_warning(
    pop$train(list(task))[[1L]],
    regexp = "Unique names for"
  )
})

test_that("ffind works", {
  expect_equal(ffind(2:5, 1, 6), c(1, 4))
  expect_equal(ffind(2:5, 6, 10), c(NA_integer_, NA_integer_))
  expect_equal(ffind(1:5, 2, 4), c(2, 4))
  x = c(1.2, 2.3, 3.4, 4.5)
  expect_equal(ffind(x, 2.5, 4), c(3, 3))
  x = c(-5, -3, -1, 1, 3)
  expect_equal(ffind(x, -3, 1), c(2, 4))
  x = c(2, 3, 4, 5)
  expect_equal(ffind(x), c(1, 4))
})
