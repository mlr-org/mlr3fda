test_that("PipeOpCor - basic properties", {
  pop = po("fda.cor")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.cor")
})

test_that("PipeOpCor works", {
  skip_if_not_installed("withr")
  withr::local_seed(1234L)
  dt = data.table(y = 1:100, x1 = tf::tf_rgp(100L), x2 = tf::tf_rgp(100L), x3 = tf::tf_rgp(100L))
  task = as_task_regr(dt, target = "y")

  pop = po("fda.cor")
  task_cor = pop$train(list(task))[[1L]]
  expect_task(task_cor)
  new_data = task_cor$data()
  expect_identical(dim(new_data), c(100L, 4L))
  expect_named(new_data, c("y", "x1_x2_cor", "x1_x3_cor", "x2_x3_cor"))
  expect_numeric(new_data$x1_x2_cor, lower = -1, upper = 1, len = 100)
  expect_numeric(new_data$x1_x3_cor, lower = -1, upper = 1, len = 100)
  expect_numeric(new_data$x2_x3_cor, lower = -1, upper = 1, len = 100)

  # single col gives warning
  task$select("x1")
  pop = po("fda.cor")
  expect_warning(pop$train(list(task)), "task has less than 2 columns")
  task_cor = suppressWarnings(pop$train(list(task))[[1L]])
  expect_identical(task$data(), task_cor$data())

  # different domain throws error
  dt_domain = copy(dt)[, x1 := tf::tf_rgp(100L, 20:120)]
  task = as_task_regr(dt_domain, target = "y")
  pop = po("fda.cor")
  expect_error(pop$train(list(task)), "Domain of x1 and x2 do not match")

  # does not touch irreg
  dt[, x1 := tf::tf_sparsify(x1)]
  task = as_task_regr(dt, target = "y")
  task_cor = pop$train(list(task))[[1L]]
  expect_set_equal(task_cor$feature_names, c("x1", "x2_x3_cor"))
})
