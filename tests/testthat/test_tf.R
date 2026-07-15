test_that("tf all-NA functional input", {
  # Canary for how tf handles all-NA functional input.
  # Historically tf::tfd() silently collapsed all-NA input to length 0 (dropping data);
  # a later tf release preserves vec_size() and returns a length-n vector of NA functions
  # with a warning instead (tidyfun/tf#33, tidyfun/tf#241, tidyfun/tf#267).
  #
  # Either way, mlr3fda's feature-extraction PipeOps do not support NA functions: like
  # mlr3pipelines::PipeOpPCA on missing values, they may error. NA functions must be
  # imputed or dropped upstream (e.g. na.omit the backing data) before feature extraction.
  dt = data.table(time = 1, value = NA_real_, id = "1")
  if (packageVersion("tf") <= "0.4.1") {
    x = tf::tfd(dt, arg = "time", value = "value", id = "id")
    expect_length(x, 0L)
  } else {
    expect_warning({
      x = tf::tfd(dt, arg = "time", value = "value", id = "id")
    })
    expect_length(x, 1L)
    expect_true(allMissing(x))
  }
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
