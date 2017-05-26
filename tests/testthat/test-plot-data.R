context("plot-data")

test_that("poly_plot_data() returns a dataframe", {
  pm <- poly(1:10, degree = 3)

  expect_s3_class(poly_plot(pm), "ggplot")
  expect_s3_class(poly_plot_data(pm), "data.frame")

  expect_named(poly_plot_data(pm), c("observation", "degree", "value"))

  expect_named(poly_plot_data(pm, by_observation = FALSE),
               c("observation", "degree", "value", "degree 1"))

  expect_named(poly_plot_data(pm, by_observation = FALSE, x_col = 3),
               c("observation", "degree", "value", "degree 3"))
})
