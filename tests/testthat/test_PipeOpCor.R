test_that("PipeOpCor - basic properties", {
  pop = po("fda.cor")
  expect_pipeop(pop)
  expect_equal(pop$id, "fda.cor")
})

test_that("PipeOpCor works", {
  set.seed(1234L)
  dt = data.table(y = 1:100, x1 = tf::tf_rgp(100L), x2 = tf::tf_rgp(100L), x3 = tf::tf_rgp(100L))
  task = as_task_regr(dt, target = "y")

  pop = po("fda.cor")
  task_cor = pop$train(list(task))[[1L]]
  expect_equal(ncol(task_cor$data()), 4L)
  expect_equal(nrow(task_cor$data()), 100L)
  expect_named(task_cor$data(), c("y", "x1_x2_cor", "x1_x3_cor", "x2_x3_cor"))

  # single col gives warning
  dt = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob", "Bob"),
    arg = rep(1:3, 2L),
    value = 1:6
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  y = c(1, 2)
  dt = data.table(f = f, y = y)
  task = as_task_regr(dt, target = "y")

  pop = po("fda.cor")
  expect_warning(pop$train(list(task)))
  new_task = suppressWarnings(pop$train(list(task))[[1L]])
  expect_identical(task$data(), new_task$data())

  # does not touch irreg
  dt = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob"),
    arg = c(1L, 7L, 2L, 3L, 5L),
    value = 1:5
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  y = 1:2
  dt = data.table(f = f, y = y)
  task = as_task_regr(dt, target = "y")
  task_cor = pop$train(list(task))[[1L]]
  expect_set_equal(task$feature_names, task_cor$feature_names)
})
