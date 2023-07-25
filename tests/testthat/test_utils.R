test_that("uniqueify_once works", {
  expect_true(uniqueify_once("a", "b") == "a")
  expect_true(uniqueify_once("a", "a") == "a_1")
  expect_true(uniqueify_once("a", c("a", "a_1")) == "a_2")
  expect_error(uniqueify_once("a", c("a", paste0("a_", 1:99))), regexp = NA)
  expect_error(uniqueify_once("a", c("a", paste0("a_", 1:100))), regexp = "Choose a better name.")
})

test_that("uniqueify works", {
  existing = c("age.mean", "height.mean", "height.mean_1", "other_name")
  wanted = c("age.mean", "height.mean")
  observed = uniqueify(wanted, existing)
  expected = c("age.mean_1", "height.mean_2")
  expect_set_equal(observed, expected)
})
