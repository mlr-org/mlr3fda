test_that("PipeOpFDARegister - basic properties", {
  pop = po("fda.register")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.register")
})

test_that("PipeOpFDARegister - affine shift registration works", {
  skip_if_not_installed("withr")
  withr::local_seed(1L)

  t = seq(0, 2 * pi, length.out = 51L)
  shifts = c(-0.3, -0.1, 0, 0.2, 0.4)
  mat = t(sapply(shifts, function(s) sin(t + s)))
  f = tf::tfd(mat, arg = t)
  dt = data.table(y = rnorm(length(shifts)), f = f)
  task = as_task_regr(dt, target = "y")

  pop = po("fda.register", method = "affine", args = list(type = "shift"))
  task_reg = train_pipeop(pop, list(task))[[1L]]
  expect_task(task_reg)
  new_data = task_reg$data()
  expect_named(new_data, c("y", "f"))
  expect_class(new_data$f, "tfd")
  expect_length(new_data$f, length(shifts))

  # template stored in state
  expect_list(pop$state$templates, len = 1L)
  expect_class(pop$state$templates$f, "tfd")
  expect_length(pop$state$templates$f, 1L)

  # predict returns same length
  new_pred = predict_pipeop(pop, list(task))[[1L]]$data()
  expect_length(new_pred$f, length(shifts))
})

test_that("PipeOpFDARegister - predict uses stored template", {
  skip_if_not_installed("withr")
  withr::local_seed(42L)

  t = seq(0, 1, length.out = 41L)
  make_curves = function(shifts) {
    mat = t(sapply(shifts, function(s) dnorm(t, mean = 0.5 + s, sd = 0.1)))
    tf::tfd(mat, arg = t)
  }
  train_f = make_curves(c(-0.1, 0, 0.1))
  test_f = make_curves(c(-0.05, 0.05))

  train_dt = data.table(y = 1:3 + 0, f = train_f)
  test_dt = data.table(y = 1:2 + 0, f = test_f)
  train_task = as_task_regr(train_dt, target = "y")
  test_task = as_task_regr(test_dt, target = "y")

  pop = po("fda.register", method = "affine", args = list(type = "shift"))
  train_pipeop(pop, list(train_task))
  tmpl_before = pop$state$templates$f

  predict_pipeop(pop, list(test_task))
  # state unchanged after predict
  expect_equal(pop$state$templates$f, tmpl_before)

  # aligning test data via predict_pipeop matches calling tf_register directly with the stored template
  reg_direct = tf::tf_register(
    test_f,
    method = "affine",
    template = tmpl_before,
    type = "shift",
    store_x = FALSE
  )
  expected = tf::tf_aligned(reg_direct)
  pred = predict_pipeop(pop, list(test_task))[[1L]]$data()
  expect_equal(pred$f, expected)
})

test_that("PipeOpFDARegister - cc method works", {
  skip_if_not_installed("withr")
  withr::local_seed(7L)

  t = seq(0, 1, length.out = 81L)
  mat = t(sapply(c(-0.08, -0.04, 0, 0.04, 0.08), function(s) dnorm(t, 0.5 + s, 0.12)))
  f = tf::tfd(mat, arg = t)
  dt = data.table(y = seq_len(5L) + 0, f = f)
  task = as_task_regr(dt, target = "y")

  pop = po("fda.register", method = "cc", args = list(nbasis = 6L, lambda = 1e-3), max_iter = 2L)
  new_data = suppressMessages(train_pipeop(pop, list(task)))[[1L]]$data()
  expect_class(new_data$f, "tfd")
  expect_length(new_data$f, 5L)
  expect_class(pop$state$templates$f, "tfd")
})

test_that("PipeOpFDARegister - srvf method works", {
  skip_if_not_installed("fdasrvf")
  skip_if_not_installed("withr")
  withr::local_seed(3L)

  t = seq(0, 1, length.out = 41L)
  mat = t(sapply(c(-0.05, 0, 0.05, 0.1), function(s) dnorm(t, 0.5 + s, 0.12)))
  f = tf::tfd(mat, arg = t)
  dt = data.table(y = 1:4 + 0, f = f)
  task = as_task_regr(dt, target = "y")

  pop = po("fda.register", method = "srvf")
  new_data = suppressMessages(train_pipeop(pop, list(task)))[[1L]]$data()
  expect_class(new_data$f, "tfd")
  expect_length(new_data$f, 4L)
  expect_class(pop$state$templates$f, "tfd")

  new_pred = suppressMessages(predict_pipeop(pop, list(task)))[[1L]]$data()
  expect_length(new_pred$f, 4L)
})

test_that("PipeOpFDARegister - multiple columns and fuel task", {
  task = tsk("fuel")
  pop = po("fda.register", method = "affine", args = list(type = "shift"))
  task_reg = suppressWarnings(suppressMessages(train_pipeop(pop, list(task))))[[1L]]
  expect_task(task_reg)
  expect_set_equal(task$feature_names, task_reg$feature_names)
  expect_list(pop$state$templates, len = 2L)
  expect_named(pop$state$templates, c("NIR", "UVVIS"))
})
