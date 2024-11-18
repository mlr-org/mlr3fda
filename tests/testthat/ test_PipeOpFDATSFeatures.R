test_that("PipeOpFDATSFeatures - basic properties", {
  pop = po("fda.tsfeats")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.tsfeats")
})
