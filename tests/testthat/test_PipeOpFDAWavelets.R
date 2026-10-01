test_that("PipeOpFDAWavelets - basic properties", {
  pop = po("fda.wavelets")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.wavelets")
})

test_that("PipeOpFDAWavelets input validation", {
  skip_if_not_installed("wavelets")
  snapshot_variant = if (packageVersion("paradox") >= "2.0.0") "paradox-2" else NULL
  expect_no_error(po("fda.wavelets", filter = wavelets::wt.filter()))
  expect_no_error(po("fda.wavelets", filter = "la8"))
  expect_no_error(po("fda.wavelets", filter = 1:10))
  expect_snapshot(po("fda.wavelets", filter = "la4"), error = TRUE, variant = snapshot_variant)
  expect_snapshot(po("fda.wavelets", filter = "invalid_filter"), error = TRUE, variant = snapshot_variant)
  expect_snapshot(po("fda.wavelets", filter = c(1, 2, 3)), error = TRUE, variant = snapshot_variant)
  expect_snapshot(po("fda.wavelets", filter = list("la8")), error = TRUE, variant = snapshot_variant)
  expect_error(po("fda.wavelets", filter = numeric(0L)))
  expect_error(po("fda.wavelets", filter = c(NA, 1)))
  expect_error(po("fda.wavelets", n.levels = 0L), "n.levels")
})

test_that("PipeOpFDAWavelets works", {
  skip_if_not_installed("wavelets")
  task = tsk("fuel")

  pop = po("fda.wavelets")
  task_wav = train_pipeop(pop, list(task))[[1L]]
  new_data = task_wav$data()
  expect_task(task_wav)
  expect_shape(new_data, dim = c(task$nrow, 362L))
  expect_match(setdiff(names(new_data), c("heatan", "h2o")), "_wav_[0-9]+$")

  pop = po("fda.wavelets", filter = "haar", boundary = "reflection")
  task_wav = train_pipeop(pop, list(task))[[1L]]
  new_data = task_wav$data()
  expect_task(task_wav)
  walk(new_data, expect_numeric)
  expect_shape(new_data, dim = c(task$nrow, 726L))
  expect_match(setdiff(names(new_data), c("heatan", "h2o")), "_wav_[0-9]+$")

  # does not touch irreg
  task = tsk("dti")
  pop = po("fda.wavelets")
  task_wav = train_pipeop(pop, list(task))[[1L]]
  expect_set_equal(task_wav$feature_names, task$feature_names)
})
