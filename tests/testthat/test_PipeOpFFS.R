test_that("PipeOpFFS works", {
  dat = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob"),
    arg = c(1, 7, 2, 3, 5),
    value = c(1, 2, 3, 4, 5)
  )
  f = tf::tfd(dat, id = "id", arg = "arg", value = "value")
  y = c(1, 2)
  dat = data.table(f = f, y = y)
  task = as_task_regr(dat, target = "y")

  po_fmean = po("ffs", feature = "mean", drop = TRUE, window = 2)
  task_fmean = po_fmean$train(list(task))[[1L]]

  feature = task_fmean$data()$f.fmean
  expect_true(all(feature == c(2, 4.5)))
  expect_set_equal(task_fmean$feature_names, c("f.mean"))

  po_fmean = po("ffs", feature = "mean", drop = FALSE)
  task_fmean = po_fmean$train(list(task))[[1L]]
  expect_set_equal(task_fmean$feature_names, c("f.mean", "f"))

  po_fmean = po("ffs", left = TRUE, window = 0, feature = "mean")
  task_fmean = po_fmean$train(list(task))[[1L]]
  task_fmean$data()
  expect_true(all(task_fmean$data()$f.fmean == c(1, 4)))

  f2 = f
  task$cbind(data.table(f2 = f2))

  po_fmean = po(
    "ffs",
    feature = "mean",
    window = c(f = 1, f2 = 2),
    drop = TRUE
  )
  task_fmean = po_fmean$train(list(task))[[1L]]
  f_fmean = task_fmean$data()$f.fmean
  f2_fmean = task_fmean$data()$f2.fmean
  expect_true(all(f_fmean == c(2, 5)))
  expect_true(all(f2_fmean == c(2.0, 4.5)))
})


test_that("fmean works", {
  dat = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob"),
    arg = c(1, 7, 2, 3, 5),
    value = c(1, 2, 3, 4, 5)
  )
  f = tf::tfd(dat, id = "id", arg = "arg", value = "value")
  observed = fmean(f, window = 3)
  expected = c(2, 4.5)
  expect_true(all(observed == expected))

  observed = fmean(f, window = Inf)
  expected = c(2, 4.5)
  expect_true(all(observed == expected))

  observed = fmean(f, window = 0)
  expected = c(2, 5)
  expect_true(all(observed == expected))

  expect_error(fmean(f, window = -0.1))
  expect_error(fmean(f, window = "hallo"))
})


test_that("PipeOpFFS works (simple test) for all features", {
  task = tsk("fuel")
  pop = po("ffs", window = 100)

  features = c("mean", "min", "max", "slope", "median")

  for (feature in features) {
    pop$param_set$values$feature = feature
    pop$param_set$values$window = 20
    expect_error(pop$train(list(task)), regexp = NA)
  }

})
