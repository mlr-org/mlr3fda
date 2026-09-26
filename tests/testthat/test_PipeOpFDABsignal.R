test_that("PipeOpFDABsignal - basic properties", {
  pop = po("fda.bsignal")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.bsignal")
})

test_that("PipeOpFDABsignal works", {
  skip_if_not_installed("FDboost")
  skip_if_not_installed("mboost")

  task = tsk("fuel")
  pop = po("fda.bsignal")
  task_bsignal = train_pipeop(pop, list(task))[[1L]]
  new_data = task_bsignal$data()
  expect_task(task_bsignal)
  expect_shape(new_data, dim = c(129L, 30L))
  expect_named(new_data, names(new_data))

  # irregular data works
  task = tsk("dti")
  pop = po("fda.bsignal")
  task_bsignal = train_pipeop(pop, list(task))[[1L]]
  new_data = task_bsignal$data()
  expect_task(task_bsignal)
})

test_that("PipeOpFDABsignal uses argument values", {
  skip_if_not_installed("FDboost")
  skip_if_not_installed("mboost")

  arg = c(0, 0.01, 0.05, 0.1, 0.2, 0.4, 0.6, 0.8, 0.9, 1)
  x = tf::tfd(matrix(sin(seq_len(50L)), nrow = 5L), arg = arg)
  task = as_task_regr(data.table(y = 1:5, x = x), target = "y")
  task_bsignal = train_pipeop(po("fda.bsignal", knots = 3L), list(task))[[1L]]
  new_data = task_bsignal$data(cols = task_bsignal$feature_names)
  expected = suppressMessages(FDboost::bsignal(as.matrix(x), s = arg, knots = 3L))
  expected = mboost::extract(expected, what = "design")
  expect_equal(unname(as.matrix(new_data)), unname(as.matrix(expected)))
})
