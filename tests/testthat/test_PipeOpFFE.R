test_that("PipeOpFFE works", {
  # Test Matrix:
  # extractors: 0, 1 or 2
  # affect_columns: 0, 1 or 2
  task = tsk("fuel")
  pop = po("ffe", extractors = list(avg = extractor_mean()), drop = FALSE)

  pop$param_set$values$affect_columns = mlr3pipelines::selector_name("xyz")
  x = pop$train(list(task))[[1L]]

  expect_set_equal(x$feature_names, task$feature_names)
  pop$param_set$values$affect_columns = mlr3pipelines::selector_all()
  x = pop$train(list(task))[[1L]]

  expect_set_equal(x$feature_names, c("NIR.avg", "UVVIS.avg", "h20", "NIR", "UVVIS"))

  pop$param_set$values$drop = TRUE
  x = pop$train(list(task))[[1L]]
  expect_set_equal(x$feature_names, c("NIR.avg", "UVVIS.avg", "h20"))


  pop = po("ffe", extractors = list(mean = extractor_mean(), slope = extractor_slope()))
  pop$param_set$values$affect_columns = mlr3pipelines::selector_name("NIR")
  pop$param_set$values$drop = TRUE
  x = pop$train(list(task))[[1L]]
  expect_set_equal(x$feature_names, c("NIR.mean", "NIR.slope", "UVVIS", "h20"))

  pop = po("ffe",
    extractors = list(mean = extractor_mean(), slope = extractor_slope()),
    drop = TRUE,
    affect_columns = mlr3pipelines::selector_all()
  )
  x = pop$train(list(task))[[1L]]
  expect_set_equal(x$feature_names, c("NIR.mean", "UVVIS.mean", "UVVIS.slope", "NIR.slope", "h20"))
})
