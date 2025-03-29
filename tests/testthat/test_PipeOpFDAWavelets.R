test_that("PipeOpFDAWavelets - basic properties", {
  pop = po("fda.wavelets")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.wavelets")
})

test_that("PipeOpFDAWavelets works", {
  task = tsk("fuel")
  pop = po("fda.wavelets")
  task_wav = train_pipeop(pop, list(task))[[1L]]
  new_data = task_wav$data()
  expect_task(task_wav)
  expect_identical(dim(new_data), c(129L, 34L))
  expect_named(new_data, names(new_data))
})
