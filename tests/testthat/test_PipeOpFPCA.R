test_that("PipeOpFPCA - basic properties", {
  pop = po("fda.fpca")
  expect_pipeop(pop)
  expect_equal(pop$id, "fda.fpca")
})

test_that("PipeOpPCA works", {
  set.seed(1234L)
  # single col works
  dt = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob", "Bob"),
    arg = rep(1:3, 2L),
    value = 1:6
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  y = c(1, 2)
  dt = data.table(f = f, y = y)
  task = as_task_regr(dt, target = "y")

  pop = po("fda.fpca")
  task_fpc = pop$train(list(task))[[1L]]
  expect_equal(nrow(task_fpc$data()), 2L)
  expect_equal(ncol(task_fpc$data()), 2L)
  expect_named(task_fpc$data(), c("y", "f_pc_1"))
  fpc = task_fpc$data()$f_pc_1
  expect_equal(fpc, c(-2.12132030, 2.12132000), tolerance = 1e-6)

  # n_components works
  dt = data.table(y = rnorm(15L), f = tf::tf_rgp(15L))
  task = as_task_regr(dt, target = "y")
  pop = po("fda.fpca", n_components = 2L)
  task_fpc = pop$train(list(task))[[1L]]
  expect_equal(ncol(task_fpc$data()), 3L)
  expect_equal(nrow(task_fpc$data()), 15L)
  expect_named(task_fpc$data(), c("y", "f_pc_1", "f_pc_2"))

  # multiple cols work
  dt = data.table(
    id = rep(1:10, each = 3L),
    arg = rep(1:3, 10L),
    value = 1:10 + rnorm(1L)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = rnorm(10L), f = f, g = f, h = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.fpca")
  task_fpc = pop$train(list(task))[[1L]]
  expect_equal(ncol(task_fpc$data()), 10L)
  expect_equal(nrow(task_fpc$data()), 10L)
  nms = c(
    "y", "f_pc_1", "f_pc_2", "f_pc_3",
    "g_pc_1", "g_pc_2", "g_pc_3",
    "h_pc_1", "h_pc_2", "h_pc_3"
  )
  expect_named(task_fpc$data(), nms)

  # n_components works
  pop = po("fda.fpca", n_components = 2L)
  task_fpc = pop$train(list(task))[[1L]]
  expect_equal(ncol(task_fpc$data()), 7L)
  expect_equal(nrow(task_fpc$data()), 10L)
  nms = c(
    "y", "f_pc_1", "f_pc_2",
    "g_pc_1", "g_pc_2",
    "h_pc_1", "h_pc_2"
  )
  expect_named(task_fpc$data(), nms)

  # affect_columns works
  pop = po("fda.fpca", affect_columns = selector_name("f"))
  task_fpc = pop$train(list(task))[[1L]]
  expect_set_equal(task_fpc$feature_names, c("f_pc_1", "f_pc_2", "f_pc_3", "g", "h"))

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
  task_fpca = pop$train(list(task))[[1L]]
  expect_set_equal(task$feature_names, task_fpca$feature_names)
})
