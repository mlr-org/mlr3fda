test_that("PipeOpScaleRange - basic properties", {
  pop = po("fda.scalerange")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.scalerange")
})

test_that("PipeOpScaleRange works", {
  task = tsk("fuel")
  pop = po("fda.scalerange")
  task_scale = pop$train(list(task))[[1L]]
  new_data = task_scale$data()
  expect_task(task_scale)
  expect_identical(dim(new_data), c(129L, 4L))
  expect_identical(task_scale$n_features, task$n_features)
  expect_named(new_data, names(new_data))
  expect_numeric(tf::tf_arg(new_data$NIR), lower = 0, upper = 1)
  expect_numeric(tf::tf_arg(new_data$UVVIS), lower = 0, upper = 1)
  expect_identical(new_data, pop$predict(list(task))[[1L]]$data())

  # different range works
  pop = po("fda.scalerange", lower = -1, upper = 1)
  task_scale = pop$train(list(task))[[1L]]
  new_data = task_scale$data()
  expect_equal(tf::tf_domain(new_data$NIR), c(-1, 1))
  expect_equal(range(tf::tf_arg(new_data$NIR)), c(-1, 1))
  expect_equal(tf::tf_domain(new_data$UVVIS), c(-1, 1))
  expect_equal(range(tf::tf_arg(new_data$UVVIS)), c(-1, 1))

  # throws error if new data has different domain
  pop = po("fda.scalerange")
  pop$train(list(task))
  expect_error(
    pop$predict(list(task_scale)),
    "Domain of new data does not match the domain of the training data."
  )

  # irregular data works
  task = tsk("dti")
  pop = po("fda.scalerange", lower = -1, upper = 1)
  new_data = pop$train(list(task))[[1L]]$data()
  expect_equal(tf::tf_domain(new_data$cca), c(-1, 1))
  expect_equal(tf::tf_domain(new_data$rcst), c(-1, 1))
})
