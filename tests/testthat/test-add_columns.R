context("add_columns")

test_that("Throws error when a column already exists", {
  df <- cbind(x = 1:10, as.data.frame(poly(1:10, 3)))
  df <- stats::setNames(df, c("x", "x1", "x2", "x3"))

  expect_error(poly_add_columns(df, x, degree = 3))
  df$x1 <- NULL
  expect_error(poly_add_columns(df, x, degree = 3))
})

test_that("Throws error when data column does not exist", {
  df <- cbind(x = 1:10, as.data.frame(poly(1:10, 3)))
  df <- stats::setNames(df, c("x", "x1", "x2", "x3"))

  expect_error(poly_add_columns(df, y, degree = 3))
})

test_that("Prefixes work", {
  df <- cbind(x = 1:10, as.data.frame(poly(1:10, 3)))
  df <- stats::setNames(df, c("x", "x1", "x2", "x3"))

  result <- poly_add_columns(df, x, degree = 3, prefix = "ox_")

  expect_named(result, c(names(df), "ox_1", "ox_2", "ox_3"))
})

test_that("Values don't change", {
  df <- cbind(x = 1:10, as.data.frame(poly(1:10, 3)))
  df <- stats::setNames(df, c("x", "x1", "x2", "x3"))

  result <- poly_add_columns(df, x, degree = 3, prefix = "ox_")

  expect_equal(result$x1, result$ox_1)
  expect_equal(result$x2, result$ox_2)
  expect_equal(result$x3, result$ox_3)
})

test_that("Repeated values get the same polynomial", {
  df <- data.frame(x = rep(rnorm(10), 3))
  result <- poly_add_columns(df, x, degree = 3)

  expect_true(length(unique(result$x1)) == length(unique(result$x)))
})

test_that("Optional rescaling works", {
  df <- data.frame(x = rep(rnorm(10), 3))
  result <- poly_add_columns(df, x, degree = 3, scale_width = 4)

  expect_equal(max(result$x1) - min(result$x1), 4)
})
