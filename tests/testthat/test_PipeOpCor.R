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
  task$select("x1")
  pop = po("fda.cor")
  expect_warning(pop$train(list(task)))
  task_cor = suppressWarnings(pop$train(list(task))[[1L]])
  expect_identical(task$data(), task_cor$data())

  # does not touch irreg
  dt[, x1 := tf::tf_sparsify(x1)]
  task = as_task_regr(dt, target = "y")
  task_cor = pop$train(list(task))[[1L]]
  expect_set_equal(task_cor$feature_names, c("x1", "x2_x3_cor"))
})
