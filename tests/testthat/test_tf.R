test_that("tf does not support NAs", {
  # Various PipeOps assume that there are no functional NAs
  # This test will inform us whether this feature is implemented,
  # in which case we then have to adress this case in the PipeOps
  # https://github.com/tidyfun/tf/issues/33
  # Currently, NA functions are dropped
  d = data.frame(time = 1, value = NA_real_, id = "1")
  x = invisible(tf::tfd(d, arg = "time", value = "value", id = "id"))
  expect_true(length(x) == 0)
})

test_that("pofu has no surprises: irreg", {
  # pofu can successfully determine that the two cca columns are identical
  task = tsk("dti")$select("cca")
  task1 = task$clone(deep = TRUE)
  task1$id = "test"
  taskout = po("featureunion")$train(list(task, task1))[[1L]]
  expect_permutation(taskout$feature_names, "cca")
})

test_that("pofu has no surprises: reg", {
  # pofu can successfully determine that the two cca columns are identical
  task = tsk("fuel")$select("NIR")
  task1 = task$clone(deep = TRUE)
  task1$id = "test"
  taskout = po("featureunion")$train(list(task, task1))[[1L]]
  expect_permutation(taskout$feature_names, "NIR")
})
