test_that("flatten_functional works", {
  f = function(x) {
    x * 10  + 7
  }
  n_obs = replicate(length(letters), sample.int(10L, 1L))
  ids = rep(letters, n_obs)
  args = rnorm(sum(n_obs))
  vals = f(args)

  funct = functional(args, vals, ids)
  ffunct = flatten_functional(funct)

  n_observed = sum(!is.na(ffunct)) # number of not nas
  n_expected = sum(map_int(funct, function(x) length(x$arg)))
  expect_true(n_observed == n_expected)

  vals_expected = sort(unlist(map(unclass(funct), "value")))
  vals_observed = sort(ffunct[!is.na(ffunct)])
  expect_true(all.equal(vals_expected, vals_observed))
})
