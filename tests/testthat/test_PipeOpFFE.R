test_that("PipeOpFFE works", {
  # Test Matrix:
  # extractors: 0, 1 or 2
  # affect_columns: 0, 1 or 2
  task = tsk("fuel")
  pop = PipeOpFFE$new()

  pop$param_set$values$extractors = list(mean = extractor_mean())
  pop$param_set$values$affect_columns = mlr3pipelines::selector_name("xyz")
  x = pop$train(list(task))[[1L]]
  expect_set_equal(x$feature_names, task$feature_names)

  pop$param_set$values$affect_columns = mlr3pipelines::selector_all()

  pop$param_set$values$extractors = list(mean = extractor_mean())
  x = pop$train(list(task))[[1L]]
  expect_set_equal(x$feature_names, c("NIR.mean", "UVVIS.mean", "h20"))

  pop$param_set$values$affect_columns = mlr3pipelines::selector_name("NIR")
  pop$param_set$values$extractors = list(mean = extractor_mean(), slope = extractor_slope())
  x = pop$train(list(task))[[1L]]
  expect_set_equal(x$feature_names, c("NIR.mean", "NIR.slope", "UVVIS", "h20"))

  pop$param_set$values$affect_columns = mlr3pipelines::selector_all()
  x = pop$train(list(task))[[1L]]
  expect_set_equal(x$feature_names, c("NIR.mean", "UVVIS.mean", "UVVIS.slope", "NIR.slope", "h20"))

  pop$param_set$values$affect_columns = mlr3pipelines::selector_all()
  x = pop$train(list(task))[[1L]]
  expect_set_equal(x$feature_names, c("NIR.mean", "UVVIS.mean", "UVVIS.slope", "NIR.slope", "h20"))
})
