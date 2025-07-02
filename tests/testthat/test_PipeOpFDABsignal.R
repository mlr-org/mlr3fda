test_that("PipeOpFDABsignal - basic properties", {
  pop = po("fda.bsignal")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.bsignal")
})

test_that("PipeOpFDABsignal works", {
  skip_if_not_installed("FDboost")

  task = tsk("fuel")
  pop = po("fda.bsignal")
  task_bsignal = train_pipeop(pop, list(task))[[1L]]
  new_data = task_bsignal$data()
  expect_task(task_bsignal)
  expect_identical(dim(new_data), c(129L, 30L))
  expect_named(new_data, names(new_data))

  # irregular data works
  task = tsk("dti")
  pop = po("fda.bsignal")
  task_bgsinal = train_pipeop(pop, list(task))[[1L]]
  new_data = task_bsignal$data()
  expect_task(task_bsignal)
})
