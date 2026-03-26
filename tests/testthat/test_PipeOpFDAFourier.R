test_that("PipeOpFDAFourier - basic properties", {
  pop = po("fda.fourier")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.fourier")
})

test_that("PipeOpFDAFourier works", {
  task = tsk("fuel")

  pop = po("fda.fourier", type = "phase")
  task_result = train_pipeop(pop, list(task))[[1L]]
  new_data = task_result$data()
  expect_task(task_result)
  # fuel NIR has 231 points (one-sided = 116), UVVIS has 134 points (one-sided = 68)
  expect_shape(new_data, dim = c(task$nrow, 2L + 116L + 68L))
  expect_match(setdiff(names(new_data), c("heatan", "h2o")), "_fft_phase_[0-9]+$")
  walk(new_data, expect_numeric)

  pop = po("fda.fourier", type = "amplitude")
  task_result = train_pipeop(pop, list(task))[[1L]]
  new_data = task_result$data()
  expect_task(task_result)
  expect_shape(new_data, dim = c(task$nrow, 2L + 116L + 68L))
  expect_match(setdiff(names(new_data), c("heatan", "h2o")), "_fft_amplitude_[0-9]+$")
  walk(new_data, expect_numeric)
})

test_that("PipeOpFDAFourier amplitude doubling is correct", {
  # odd n: all positive frequencies doubled, no Nyquist
  pop = po("fda.fourier", type = "amplitude")
  x_odd = tf::tfd(list(c(1, 2, 3, 4, 5)), arg = 1:5)
  task_odd = as_task_regr(data.table(x = x_odd, y = 1), target = "y")
  res_odd = train_pipeop(pop, list(task_odd))[[1L]]$data()
  fft_raw = stats::fft(c(1, 2, 3, 4, 5)) / 5
  expected = Mod(fft_raw[1:3])
  expected[2:3] = expected[2:3] * 2
  actual = as.numeric(res_odd[1L, grep("^x_fft", names(res_odd)), with = FALSE])
  expect_equal(actual, expected, tolerance = 1e-10)

  # even n: Nyquist (last) not doubled
  pop = po("fda.fourier", type = "amplitude")
  x_even = tf::tfd(list(c(1, 2, 3, 4)), arg = 1:4)
  task_even = as_task_regr(data.table(x = x_even, y = 1), target = "y")
  res_even = train_pipeop(pop, list(task_even))[[1L]]$data()
  fft_raw4 = stats::fft(c(1, 2, 3, 4)) / 4
  expected4 = Mod(fft_raw4[1:3])
  expected4[2] = expected4[2] * 2
  actual4 = as.numeric(res_even[1L, grep("^x_fft", names(res_even)), with = FALSE])
  expect_equal(actual4, expected4, tolerance = 1e-10)

  # n = 2: DC + Nyquist only, nothing doubled
  pop = po("fda.fourier", type = "amplitude")
  x_two = tf::tfd(list(c(1, 3)), arg = 1:2)
  task_two = as_task_regr(data.table(x = x_two, y = 1), target = "y")
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
