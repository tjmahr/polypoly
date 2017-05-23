
#' Melt a polynomial matrix
#'
#' @param x a matrix created by [stats::poly()]
#' @return a [tibble::tibble()] with three columns: `observation`, `degree`, and
#'   `value`.
#' @export
poly_melt <- function(x) {
  df <- reshape2::melt(x, c("observation", "degree"), "value", as.is = TRUE)
  tibble::as_tibble(df)
}

#' Plot a polynomial matrix
#'
#' @param x a matrix created by [stats::poly()]
#' @return a [ggplot2::ggplot()] plot of the degree terms from the matrix
#' @export
poly_plot <- function(x) {
  df <- poly_melt(x)
  df$degree <- factor(df$degree, levels = colnames(x))

  # Should I try to avoid loading ggplot2?
  `%+p%` <- ggplot2::`%+%`
  p <- ggplot2::ggplot(df) %+p%
    ggplot2::aes_(x = ~ observation, y = ~ value, color = ~ degree) %+p%
    ggplot2::geom_line()
  p
}
