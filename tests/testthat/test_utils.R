test_that("uniqueify works", {
  expect_true(uniqueify("a", "b") == "a")
  expect_true(uniqueify("a", "a") == "a_1")
  expect_true(uniqueify("a", c("a", "a_1")) == "a_2")
  expect_error(uniqueify("a", c("a", paste0("a_", 1:99))), regexp = NA)
  expect_error(uniqueify("a", c("a", paste0("a_", 1:100))), regexp = "Choose a better name.")
})
