test_that("PipeOpFDAWavelets - basic properties", {
  pop = po("fda.wavelets")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.wavelets")
})

test_that("PipeOpFDAWavelets input validation validation", {
  skip_if_not_installed("wavelets")
  expect_no_error(po("fda.wavelets", filter = wavelets::wt.filter()))
  expect_no_error(po("fda.wavelets", filter = "la8"))
  expect_no_error(po("fda.wavelets", filter = 1:10))
  expect_snapshot(po("fda.wavelets", filter = "la4"), error = TRUE)
  expect_snapshot(po("fda.wavelets", filter = "invalid_filter"), error = TRUE)
  expect_snapshot(po("fda.wavelets", filter = c(1, 2, 3)), error = TRUE)
  expect_snapshot(po("fda.wavelets", filter = list("la8")), error = TRUE)
})

test_that("PipeOpFDAWavelets works", {
  skip_if_not_installed("wavelets")
  task = tsk("fuel")

  pop = po("fda.wavelets")
  task_wav = train_pipeop(pop, list(task))[[1L]]
  new_data = task_wav$data()
  expect_task(task_wav)
  expect_identical(dim(new_data), c(task$nrow, 362L))
  expect_match(setdiff(names(new_data), c("heatan", "h20")), "_wav_la8_[0-9]+$")

  pop = po("fda.wavelets", filter = "haar", boundary = "reflection")
  task_wav = train_pipeop(pop, list(task))[[1L]]
  new_data = task_wav$data()
  expect_task(task_wav)
  walk(new_data, expect_numeric)
  expect_identical(dim(new_data), c(task$nrow, 726L))
  expect_match(setdiff(names(new_data), c("heatan", "h20")), "_wav_haar_[0-9]+$")

  # irregular data works
  task = tsk("dti")
  task$select(setdiff(task$feature_names, "sex"))
  pop = po("fda.wavelets")
  task_wav = train_pipeop(pop, list(task))[[1L]]
  new_data = task_wav$data()
  expect_task(task_wav)
  walk(new_data, expect_numeric)
  expect_identical(dim(new_data), c(task$nrow, 144L))
  expect_match(setdiff(names(new_data), "pasat"), "_wav_la8_[0-9]+$")
})
