test_that("PipeOpFDASmooth - basic properties", {
  pop = po("fda.smooth")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.smooth")
})

test_that("PipeOpFDASmooth", {
  test_cca = function(method, args) {
    po_smooth = po("fda.smooth")
    x = task2$data(cols = "cca")$cca

    po_smooth$param_set$set_values(method = method, args = args)
    observed_train = train_pipeop(po_smooth, list(task2))[[1L]]$data(cols = "cca")[[1L]]
    observed_predict = predict_pipeop(po_smooth, list(task2))[[1L]]$data(cols = "cca")[[1L]]

    expected = suppressMessages(invoke(tf::tf_smooth, x = x, method = method, .args = args))

    expect_equal(observed_train, expected)
    expect_equal(observed_predict, expected)
  }

  test_nir = function(method, args) {
    po_smooth = po("fda.smooth")
    x = task1$data(cols = "NIR")$NIR

    po_smooth$param_set$set_values(method = method, args = args)
    observed_train = train_pipeop(po_smooth, list(task1))[[1L]]$data(cols = "NIR")[[1L]]
    observed_predict = predict_pipeop(po_smooth, list(task1))[[1L]]$data(cols = "NIR")[[1L]]

    expected = suppressMessages(invoke(tf::tf_smooth, x = x, method = method, .args = args))

    expect_equal(observed_train, expected)
    expect_equal(observed_predict, expected)
  }

  # regular
  task1 = tsk("fuel")
  task1$col_roles$feature = "NIR"
  # irregular
  task2 = tsk("dti")
  task2$col_roles$feature = "cca"

  test_nir("lowess", list(f = 0.3))
  test_cca("lowess", list(f = 0.2))

  test_nir("rollmean", list(k = 5))
  test_nir("rollmedian", list())
  test_nir("savgol", list())

  # verbose parameter is respected
  po_smooth = po("fda.smooth")
  po_smooth$param_set$set_values(verbose = TRUE)
  expect_snapshot(train_pipeop(po_smooth, list(task1)))
  po_smooth = po("fda.smooth")
  po_smooth$param_set$set_values(verbose = FALSE)
  expect_no_message(train_pipeop(po_smooth, list(task1)))
})
