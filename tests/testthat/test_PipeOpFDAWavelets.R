test_that("PipeOpFDAWavelets - basic properties", {
  pop = po("fda.wavelets")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.wavelets")
})
