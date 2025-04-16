test_that("PipeOpFDATsfeatures - basic properties", {
  pop = po("fda.tsfeats")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.tsfeats")
})

test_that("PipeOpFDATsfeatures works", {
  skip_if_not_installed("tsfeatures")

  task = tsk("fuel")
  pop = po("fda.tsfeats")
  task_tsfeats = train_pipeop(pop, list(task))[[1L]]
  new_data = task_tsfeats$data()
  expect_task(task_tsfeats)
  expect_identical(dim(new_data), c(129L, 34L))
  expect_named(new_data, names(new_data))

  # single feature work
  pop = po("fda.tsfeats", features = "entropy")
  task_tsfeats = train_pipeop(pop, list(task))[[1L]]
  new_data = task_tsfeats$data()
  walk(new_data, expect_numeric)
  expect_identical(dim(new_data), c(129L, 4L))
  expect_named(new_data, c("heatan", "h20", "NIR_entropy", "UVVIS_entropy"))

  # multiple features work
  pop = po("fda.tsfeats", features = c("frequency", "stl_features"))
  task_tsfeats = train_pipeop(pop, list(task))[[1L]]
  new_data = task_tsfeats$data()
  walk(new_data, expect_numeric)
  expect_identical(dim(new_data), c(129L, 20L))
  expect_match(setdiff(names(new_data), c("heatan", "h20")), "NIR_|UVVIS_")

  # irregular data works
  task = tsk("dti")
  pop = po("fda.tsfeats")
  task_tsfeats = train_pipeop(pop, list(task))[[1L]]
  new_data = task_tsfeats$data()
  expect_task(task_tsfeats)
})
