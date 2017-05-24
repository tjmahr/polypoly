
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

#' Plot a polynomial matrix
#'
#' @param x a matrix created by [stats::poly()]
#' @param by_observation whether the plot's x axis should be the observation/row
#'   number (TRUE, the default), or whether it should be the degree-1 terms
#'   (FALSE)
#' @return a [ggplot2::ggplot()] plot of the degree terms from the matrix
#' @export
poly_plot <- function(x, by_observation = TRUE) {
  df <- poly_melt(x)
  df$degree <- factor(df$degree, levels = colnames(x))
  x_var <- "observation"

  if (!by_observation) {
    df1 <- df[df$degree == colnames(x)[1], ]
    x_var <- paste0("degree ", colnames(x)[1])
    df1[x_var] <- df1$value
    df1$degree <- NULL
    df1$value <- NULL
    df <- merge(df, df1, by = "observation")
  }

  # Should I try to avoid loading ggplot2?
  `%+p%` <- ggplot2::`%+%`
  p <- ggplot2::ggplot(df) %+p%
    ggplot2::aes_(x = as.name(x_var), y = ~ value, color = ~ degree) %+p%
    ggplot2::geom_line()
  p
}
