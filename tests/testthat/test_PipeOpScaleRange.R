test_that("PipeOpScale - basic properties", {
  pop = po("fda.scalerange")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.scalerange")
})
