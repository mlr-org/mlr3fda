test_that("PipeOpFDAScaleRange - basic properties", {
  pop = po("fda.scalerange")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.scalerange")
})

test_that("PipeOpFDAScaleRange works", {
  task = tsk("fuel")
  pop = po("fda.scalerange")
  task_scale = train_pipeop(pop, list(task))[[1L]]
  new_data = task_scale$data()
  expect_task(task_scale)
  expect_shape(new_data, dim = c(129L, 4L))
  expect_identical(task_scale$n_features, task$n_features)
  expect_named(new_data, names(new_data))
  expect_numeric(tf::tf_arg(new_data$NIR), lower = 0, upper = 1)
  expect_numeric(tf::tf_arg(new_data$UVVIS), lower = 0, upper = 1)
  expect_identical(new_data, predict_pipeop(pop, list(task))[[1L]]$data())

  # different range works
  pop = po("fda.scalerange", lower = -1, upper = 1)
  task_scale = train_pipeop(pop, list(task))[[1L]]
  new_data = task_scale$data()
  expect_equal(tf::tf_domain(new_data$NIR), c(-1, 1))
  expect_equal(range(tf::tf_arg(new_data$NIR)), c(-1, 1))
  expect_equal(tf::tf_domain(new_data$UVVIS), c(-1, 1))
  expect_equal(range(tf::tf_arg(new_data$UVVIS)), c(-1, 1))

  # throws error if new data has different domain
  pop = po("fda.scalerange")
  train_pipeop(pop, list(task))
  expect_error(
    predict_pipeop(pop, list(task_scale)),
    "Domain of column 'NIR' does not match its domain during training."
  )

  # irregular data works
  task = tsk("dti")
  pop = po("fda.scalerange", lower = -1, upper = 1)
  new_data = train_pipeop(pop, list(task))[[1L]]$data()
  expect_equal(tf::tf_domain(new_data$cca), c(-1, 1))
  expect_equal(tf::tf_domain(new_data$rcst), c(-1, 1))
})

test_that("PipeOpFDAScaleRange keeps evaluator and scales domain", {
  x = tf::tfd(matrix(1:6, nrow = 2L), arg = c(0, 0.5, 1), domain = c(-1, 2), evaluator = tf_approx_spline)
  task = as_task_regr(data.table(y = 1:2, x = x), target = "y")
  pop = po("fda.scalerange")
  new_x = train_pipeop(pop, list(task))[[1L]]$data()$x
  expect_identical(attr(new_x, "evaluator_name"), "tf_approx_spline")
  expect_equal(tf::tf_domain(new_x), c(0, 1))
  expect_equal(tf::tf_arg(new_x), c(1, 1.5, 2) / 3)
  expect_equal(predict_pipeop(pop, list(task))[[1L]]$data()$x, new_x)
})

test_that("PipeOpFDAScaleRange state does not clash with base class state", {
  task = as_task_regr(data.table(y = 1:5, dt_columns = tf::tf_rgp(5L)), target = "y")
  pop = po("fda.scalerange", upper = 2)
  train_data = train_pipeop(pop, list(task))[[1L]]$data()
  expect_named(pop$state$trafos, "dt_columns")
  expect_identical(pop$state$dt_columns, "dt_columns")
  expect_equal(predict_pipeop(pop, list(task))[[1L]]$data(), train_data)
})

test_that("PipeOpFDAScaleRange errors if lower is not smaller than upper", {
  task = tsk("fuel")
  expect_error(train_pipeop(po("fda.scalerange", lower = 1, upper = 0), list(task)), "'lower' must be smaller")
  expect_error(train_pipeop(po("fda.scalerange", lower = 1, upper = 1), list(task)), "'lower' must be smaller")
})
