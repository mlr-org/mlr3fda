test_that("PipeOpFDACatch22 - basic properties", {
  pop = po("fda.catch22")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.catch22")
})

test_that("PipeOpFDACatch22 works", {
  skip_if_not_installed("Rcatch22")

  task = tsk("fuel")
  pop = po("fda.catch22")
  task_catch22 = train_pipeop(pop, list(task))[[1L]]
  new_data = task_catch22$data()
  expect_task(task_catch22)
  walk(new_data, expect_numeric)
  expect_shape(new_data, dim = c(129L, 46L))
  expect_match(setdiff(names(new_data), c("heatan", "h2o")), "NIR_|UVVIS_")

  # catch24 adds mean and standard deviation
  pop = po("fda.catch22", catch24 = TRUE)
  task_catch22 = train_pipeop(pop, list(task))[[1L]]
  new_data = task_catch22$data()
  expect_shape(new_data, dim = c(129L, 50L))
  expect_subset(c("NIR_DN_Mean", "NIR_DN_Spread_Std"), names(new_data))

  # irregular data works
  task = tsk("dti")
  pop = po("fda.catch22")
  task_catch22 = train_pipeop(pop, list(task))[[1L]]
  expect_task(task_catch22)
})
