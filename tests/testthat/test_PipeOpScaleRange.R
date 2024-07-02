test_that("PipeOpScaleRange - basic properties", {
  pop = po("fda.scalerange")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.scalerange")
})

test_that("PipeOpScaleRange works", {
  task = tsk("fuel")
  pop = po("fda.scalerange")
  task_scale = pop$train(list(task))[[1L]]
  expect_identical(dim(task_scale$data()), c(129L, 4L))
  expect_identical(task_scale$n_features, task$n_features)
  expect_setequal(names(task_scale$data()), names(task$data()))
  expect_numeric(tf::tf_arg(task_scale$data()$NIR), lower = 0, upper = 1)
  expect_numeric(tf::tf_arg(task_scale$data()$UVVIS), lower = 0, upper = 1)

  # different range works
  pop = po("fda.scalerange", lower = -1, upper = 1)
  task_scale = pop$train(list(task))[[1L]]
  expect_equal(range(tf::tf_arg(task_scale$data()$NIR)), c(-1, 1))
  expect_equal(range(tf::tf_arg(task_scale$data()$UVVIS)), c(-1, 1))

  # throws error if new data has different domain
  pop = po("fda.scalerange")
  pop$train(list(task))
  expect_error(
    pop$predict(list(task_scale)),
    "Domain of new data does not match the domain of the training data."
  )
})
