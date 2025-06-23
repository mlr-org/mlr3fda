test_that("PipeOpFDAZoom - basic properties", {
  pop = po("fda.zoom")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.zoom")
})

test_that("PipeOpScaleRange works", {
  task = tsk("fuel")
  pop = po("fda.zoom", begin = 50, end = 100)
  task_zoom = train_pipeop(pop, list(task))[[1L]]
  new_data = task_zoom$data()
  expect_task(task_zoom)
  expect_identical(dim(new_data), c(129L, 4L))
  expect_identical(task_zoom$n_features, task$n_features)
  expect_named(new_data, names(new_data))
  expect_numeric(tf::tf_arg(new_data$NIR), lower = 50, upper = 100)
  expect_numeric(tf::tf_arg(new_data$UVVIS), lower = 50, upper = 100)
  expect_identical(tf::tf_domain(new_data$NIR), c(50, 100))
  expect_identical(tf::tf_domain(new_data$UVVIS), c(50, 100))
  expect_identical(new_data, predict_pipeop(pop, list(task))[[1L]]$data())

  # irregular data works
  task = tsk("dti")
  pop = po("fda.zoom", begin = 0.2, end = 0.8)
  new_data = train_pipeop(pop, list(task))[[1L]]$data()
  expect_identical(tf::tf_domain(new_data$cca), c(0.2, 0.8))
  expect_identical(tf::tf_domain(new_data$rcst), c(0.2, 0.8))
})
