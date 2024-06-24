library(mlr3)
library(checkmate)
library(mlr3misc)
library(mlr3pipelines)
library(R6)
library(paradox)

lapply(list.files(system.file("testthat", package = "mlr3"), pattern = "^helper.*\\.[rR]", full.names = TRUE), source)
lapply(list.files(system.file("testthat", package = "mlr3pipelines"), pattern = "^helper.*\\.[rR]", full.names = TRUE), source)

test_that("ffind works", {
  expect_equal(ffind(1:5, 2, 4), c(2, 4))
  x = 0:10 * 3
  expect_equal(ffind(x, 9, 25), c(4, 9))
  expect_equal(ffind(x, 9.5, 24.5), c(5, 9))
  expect_equal(ffind(x, 9.5, 21.5), c(5, 8))
  expect_equal(ffind(-5:5, -3, 3), c(3, 9))
  expect_equal(ffind(1:10, 1, 10), c(1, 10))
  # non-integer
  x = c(1.2, 2.3, 3.4, 4.5)
  expect_equal(ffind(x, 2.5, 4), c(3, 3))
  # min/max
  x = c(2, 3, 4, 4)
  expect_equal(ffind(x), c(1, 4))
  expect_equal(ffind(1:10, -1, 11), c(1, 10))
  # negative numbers
  x = c(-5, -3, -1, 1, 3)
  expect_equal(ffind(x, -3, 1), c(2, 4))
  # not in interval
  expect_equal(ffind(2:5, 6, 10), c(NA_integer_, NA_integer_))
  expect_equal(ffind(2:5, 1, 1), c(NA_integer_, NA_integer_))
  expect_equal(ffind(1:10, 20, 30), c(NA_integer_, NA_integer_))
  # single element
  expect_equal(ffind(5, 5, 5), c(1, 1))
  expect_equal(ffind(5, 4, 6), c(1, 1))
  expect_equal(ffind(5, 6, 7), c(NA_integer_, NA_integer_))
  # NA values
  x = c(2, NA, 4, 5)
  expect_equal(ffind(x, 2, 5), c(1, 4))
  # large vector
  x = 1:1e6
  expect_equal(ffind(x, 1e5, 1e6), c(1e5, 1e6))
  # lower and upper same value
  expect_equal(ffind(1:3, 1, 1), c(1, 1))
  # not in interval
  expect_equal(ffind(1:3, 1.1, 1.2), c(NA_integer_, NA_integer_))
  expect_equal(ffind(1:3, 1.3, 1.8), c(NA_integer_, NA_integer_))
  # left not in interval
  expect_equal(ffind(1:3, 1.2, 2), c(2, 2))
  # right not in interval
  expect_equal(ffind(1:3, 1, 1.2), c(1, 1))
  # one boundary outside
  expect_equal(ffind(1:10, 0, 5), c(1, 5))
  expect_equal(ffind(1:10, 5, 15), c(5, 10))

  expect_equal(
    ffind(
      c(-3876, -3798, -3453, -3363, -2974, -2953, -2871, -1917, -1335, -1304, -725, 10),
      left = -200, right = 0
    ),
    rep(NA_integer_, 2L)
  )
})
