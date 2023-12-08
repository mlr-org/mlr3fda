test_that("tf does not support NAs", {
  # Various PipeOps assume that there are no functional NAs
  # This test will inform us whether this feature is implemented,
  # in which case we then have to adress this case in the PipeOps
  # https://github.com/tidyfun/tf/issues/33
  # Currently, NA functions are dropped
  d = data.frame(time = 1, value = NA_real_, id = "1")
  x = invisible(tfd(d, arg = "time", value = "value", id = "id"))
  expect_true(length(x) == 0)
})
