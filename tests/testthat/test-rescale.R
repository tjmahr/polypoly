context("rescale")

test_that("Rescaling changes the width of the first column", {
  m <- poly(1:10, degree = 3)
  result <- poly_rescale(m, 1)
  expect_equal(max(result[, 1]) - min(result[, 1]), 1)

  result <- poly_rescale(m, 10)
  expect_equal(max(result[, 1]) - min(result[, 1]), 10)
})

test_that("Rescaling tolerates NULLs", {
  m <- poly(1:10, degree = 3)
  result <- poly_rescale(m, NULL)

  # This expectation would fail because of the extra "poly" class, so we change
  # the class on the original matrix.
  class(m) <- "matrix"
  expect_equivalent(m, result)
})

test_that("Rescaling is mathematically sound", {
  # i.e., rescaled values are still orthogonal
  m <- poly(1:10, degree = 3)
  result <- poly_rescale(m, scale_width = 10)
  expect_equivalent(zapsmall(cor(result)), diag(3))
})
