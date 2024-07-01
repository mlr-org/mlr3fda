test_that("PipeOpScale - basic properties", {
  pop = po("fda.scale")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.scale")
})
