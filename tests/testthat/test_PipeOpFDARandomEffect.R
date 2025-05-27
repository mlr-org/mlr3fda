test_that("PipeOpFDARandomEffect - basic properties", {
  pop = po("fda.random_effect")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.random_effect")
})

test_that("PipeOpFDARandomEffect works", {
  skip_if_not_installed("lme4")

  task = tsk("fuel")
  pop = po("fda.random_effect")
  task_fre = suppressWarnings(train_pipeop(pop, list(task))[[1L]])
  new_data = task_fre$data()
  expect_task(task_fre)
  expect_identical(dim(new_data), c(129L, 6L))
  expect_named(
    new_data,
    c("heatan", "h20", "NIR_random_intercept", "NIR_random_slope", "UVVIS_random_intercept", "UVVIS_random_slope")
  )

  # irregular data works
  task = tsk("dti")
  pop = po("fda.random_effect")
  task_fre = train_pipeop(pop, list(task))[[1L]]
  new_data = task_fre$data()
  expect_task(task_fre)
  expect_identical(dim(new_data), c(340L, 6L))
  expect_named(
    new_data,
    c("pasat", "sex", "cca_random_intercept", "cca_random_slope", "rcst_random_intercept", "rcst_random_slope")
  )
})
