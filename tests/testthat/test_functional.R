test_that("functional works", {
  f = function(x) {
    x * 3 + 1
  }

  ids_orig = letters[1:10]
  nobs = replicate(10, sample.int(10, 1))
  ids = rep(ids_orig, times = nobs)
  args = unlist(lapply(nobs, function(x) sort(runif(x))))
  values = f(args)
  funct = functional(args, values, ids)
  expect_true(inherits(funct, "functional"))
})


test_that("as_functional works for matrix", {
  m = matrix(runif(1000L), ncol = 10L)
  f = as_functional(m, arguments = 1:10)
})

test_that("as_function works for data.table", {
  f = function(x) {
    x * 3 + 1
  }
  ids_orig = letters[1:10]
  nobs = replicate(10, sample.int(10, 1))
  ids = rep(ids_orig, times = nobs)
  args = unlist(lapply(nobs, function(x) sort(runif(x))))
  values = f(args)
  dt = data.table(x = args, y = values, z = ids)
  funct = as_functional(dt, arg = "x", value = "y", id = "z")

})
