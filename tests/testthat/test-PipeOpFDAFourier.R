test_that("PipeOpFDAFourier - basic properties", {
  pop = po("fda.fourier")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.fourier")
})

test_that("PipeOpFDAFourier works with phase", {
  task = tsk("fuel")
  pop = po("fda.fourier", trafo_coeff = "phase")
  task_result = train_pipeop(pop, list(task))[[1L]]
  expect_task(task_result)
  fft_feats = grep("_fft_phase_", task_result$feature_names, value = TRUE)
  expect_true(length(fft_feats) > 0L)
})

test_that("PipeOpFDAFourier works with amplitude", {
  task = tsk("fuel")
  pop = po("fda.fourier", trafo_coeff = "amplitude")
  task_result = train_pipeop(pop, list(task))[[1L]]
  expect_task(task_result)
  fft_feats = grep("_fft_amplitude_", task_result$feature_names, value = TRUE)
  expect_true(length(fft_feats) > 0L)
})

test_that("PipeOpFDAFourier returns one-sided spectrum", {
  task = tsk("fuel")
  pop = po("fda.fourier")
  task_result = train_pipeop(pop, list(task))[[1L]]
  # fuel NIR has 231 points, one-sided = 231 %/% 2 + 1 = 116
  nir_feats = grep("^NIR_fft_", task_result$feature_names, value = TRUE)
  expect_identical(length(nir_feats), 116L)
})

test_that("PipeOpFDAFourier amplitude DC is not doubled", {
  task = tsk("fuel")
  pop = po("fda.fourier", trafo_coeff = "amplitude")
  task_result = train_pipeop(pop, list(task))[[1L]]
  dt = task_result$data()
  # DC component (index 1) should equal mean of signal / n * n = mean
  nir_vals = tf::tf_evaluations(tsk("fuel")$data(cols = "NIR")$NIR)
  dc = mean(nir_vals[[1L]])
  expect_equal(dt$NIR_fft_amplitude_1[[1L]], abs(dc), tolerance = 1e-6)
})

test_that("PipeOpFDAFourier amplitude doubling correct for odd n", {
  # odd n: all positive frequencies should be doubled (no Nyquist)
  pop = po("fda.fourier", trafo_coeff = "amplitude")
  x_odd = tf::tfd(list(c(1, 2, 3, 4, 5)), arg = 1:5)
  dt_odd = data.table(x = x_odd, y = 1)
  task_odd = as_task_regr(dt_odd, target = "y")
  res_odd = train_pipeop(pop, list(task_odd))[[1L]]$data()
  fft_raw = stats::fft(c(1, 2, 3, 4, 5)) / 5
  expected = Mod(fft_raw[1:3])
  expected[2:3] = expected[2:3] * 2
  actual = as.numeric(res_odd[1L, grep("^x_fft", names(res_odd)), with = FALSE])
  expect_equal(actual, expected, tolerance = 1e-10)
})

test_that("PipeOpFDAFourier amplitude doubling correct for even n", {
  # even n: Nyquist (last) should not be doubled
  pop = po("fda.fourier", trafo_coeff = "amplitude")
  x_even = tf::tfd(list(c(1, 2, 3, 4)), arg = 1:4)
  dt_even = data.table(x = x_even, y = 1)
  task_even = as_task_regr(dt_even, target = "y")
  res_even = train_pipeop(pop, list(task_even))[[1L]]$data()
  fft_raw4 = stats::fft(c(1, 2, 3, 4)) / 4
  expected4 = Mod(fft_raw4[1:3])
  expected4[2] = expected4[2] * 2
  actual4 = as.numeric(res_even[1L, grep("^x_fft", names(res_even)), with = FALSE])
  expect_equal(actual4, expected4, tolerance = 1e-10)
})

test_that("PipeOpFDAFourier amplitude doubling correct for n = 2", {
  # n = 2: DC + Nyquist, nothing doubled
  pop = po("fda.fourier", trafo_coeff = "amplitude")
  x_two = tf::tfd(list(c(1, 3)), arg = 1:2)
  dt_two = data.table(x = x_two, y = 1)
  task_two = as_task_regr(dt_two, target = "y")
  res_two = train_pipeop(pop, list(task_two))[[1L]]$data()
  fft_raw2 = stats::fft(c(1, 3)) / 2
  expected2 = Mod(fft_raw2[1:2])
  actual2 = as.numeric(res_two[1L, grep("^x_fft", names(res_two)), with = FALSE])
  expect_equal(actual2, expected2, tolerance = 1e-10)
})

test_that("PipeOpFDAFourier predict works", {
  task = tsk("fuel")
  pop = po("fda.fourier")
  train_pipeop(pop, list(task))
  task_result = predict_pipeop(pop, list(task))[[1L]]
  expect_task(task_result)
})
