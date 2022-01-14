#' polypoly: Helper functions for orthogonal polynomials
#'
#' This package provides helpful functions for orthogonal polynomials created by
#' [stats::poly()]. These include plotting [poly_plot()], tidying [poly_melt()],
#' rescaling [poly_rescale()], and manipulating a dataframe
#' [poly_add_columns()].
#'
#' @name polypoly
#' @docType package
#' @author Tristan Mahr
NULL




#' Melt a polynomial matrix
#'
#' @param x a matrix created by [stats::poly()]
#' @return a [tibble::tibble()] with three columns: `observation` (row number of
#'   the matrix), polynomial `degree`, and `value`.
#' @export
#' @details The `degree` values are returned as a character vector because they
#'   should be treated categorically (as when plotting). Moreover, matrices
#'   made with multiple vectors (e.g., `poly(rnorm(10), rnorm(10), degree = 2)`)
#'   have names that are not numerically meaningful (e.g., `1.0`, `2.0`, `0.1`,
#'   `1.1`, `0.2`),
#'
#' @examples
#' m <- poly(rnorm(10), degree = 3)
#' poly_melt(m)
poly_melt <- function(x) {
  df <- reshape2::melt(x, c("observation", "degree"), "value", as.is = TRUE)
  tibble::as_tibble(df)
}




#' Plot a polynomial matrix
#'
#' @param x a matrix created by [stats::poly()]
#' @param by_observation whether the x axis should be mapped to the
#'   observation/row number (`TRUE`, the default) or to the degree-1 terms of
#'   the matrix (`FALSE`)
#' @param x_col integer indicating which column to plot as the x-axis when
#'   `by_observation` is `FALSE`. Default is 1 (assumes the first column is the
#'   linear polynomial term).
#' @return a [ggplot2::ggplot()] plot of the degree terms from the matrix. For
#'   `poly_plot_data()`, the dataframe used to create the plot is returned
#'   instead.
#' @export
#' @examples
#' # Defaults to plotting using the row number as x-axis
#' m <- poly(1:100, degree = 3)
#' poly_plot(m)
#'
#' # Not good because observations were not sorted
#' m2 <- poly(rnorm(100), degree = 3)
#' poly_plot(m2)
#'
#' # Instead set by_observation to FALSE to plot along the degree 1 values
#' poly_plot(m2, by_observation = FALSE)
#'
#' # Get a dataframe instead of plot
#' poly_plot_data(m2, by_observation = FALSE)
poly_plot <- function(x, by_observation = TRUE, x_col = 1) {
  poly_plot_backend(x, by_observation, x_col, just_data = FALSE)
}

#' @rdname poly_plot
#' @export
poly_plot_data <- function(x, by_observation = TRUE, x_col = 1) {
  poly_plot_backend(x, by_observation, x_col, just_data = TRUE)
}

poly_plot_backend <- function(x, by_observation = TRUE, x_col = 1, just_data) {
  df <- poly_melt(x)
  df$degree <- factor(df$degree, levels = colnames(x))
  x_var <- "observation"

  if (!by_observation) {
    df1 <- df[df$degree == colnames(x)[x_col], , drop = FALSE]
    x_var <- paste0("degree ", colnames(x)[x_col])
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

  if (just_data) {
    tibble::as_tibble(df)
  } else {
    p
  }
}




#' Add orthogonal polynomial columns to a dataframe
#' @param .data a dataframe
#' @param .col a bare column name
#' @param degree number of polynomial terms to add to the dataframe
#' @param prefix prefix for the names to add to the dataframe. default is the
#'   name of `.col`.
#' @param scale_width optionally rescale the dataframe using [poly_rescale()].
#'   Default behavior is not to perform any rescaling.
#' @return the dataframe with additional columns of orthogonal polynomial terms
#'   of `.col`
#' @export
#' @examples
#' df <- data.frame(time = rep(1:5, 3), y = rnorm(15))
#'
#' # adds columns "time1", "time2", "time3"
#' poly_add_columns(df, time, degree = 3)
#'
#' # adds columns "t1", "t2", "t3 and rescale
#' poly_add_columns(df, time, degree = 3, prefix = "t", scale_width = 1)
poly_add_columns <- function(.data, .col, degree = 1, prefix = NULL,
                             scale_width = NULL) {
  # Support nonstandard evaluation
  .col <- rlang::enquo(.col)
  .col_name <- rlang::quo_name(.col)
  stopifnot(.col_name %in% names(.data))

  # Get the unique values
  x <- rlang::eval_tidy(.col, .data)
  x <- sort(unique(x))

  # Create the polynomial basis
  m <- stats::poly(x, degree = degree, simple = TRUE)
  m <- poly_rescale(m, scale_width)

  # Name the new columns
  prefix <- ifelse(is.null(prefix), .col_name, prefix)
  names <- paste0(prefix, seq_len(degree))

  # Fail if name already exists
  if (any(names %in% colnames(.data))) {
    example_name <- colnames(.data)[which(colnames(.data) %in% names)][1]
    stop("Column `", example_name, "` already exists. Try a different prefix.",
         call. = FALSE)
  }

  # Merge orthogonal terms into data-set
  df <- as.data.frame(cbind(x, m))
  df <- rlang::set_names(df, c(.col_name, names))
  .data2 <- .data
  .data2["...rowid"] <- seq_len(nrow(.data2))

  # Preserve order of original data-frame
  merged <- merge(.data2, df, by = .col_name)
  merged <- merged[order(merged[["...rowid"]]), , drop = FALSE]
  merged[["...rowid"]] <- NULL

  cols_to_add <- as.list(merged)[names]
  tibble::add_column(.data, !!!(cols_to_add))
}




#' Rescale the range of a polynomial matrix
#'
#' @param x a matrix created by [stats::poly()]
#' @param scale_width the desired range (max - min) for the first column of the matrix
#' @return the rescaled polynomial matrix (as a plain matrix with `coefs`
#'   attribute removed)
#' @export
#' @details This function strips away the `poly` class and the `coefs`
#'   attribute of the matrix. This is because those attributes no longer
#'   describe the transformed matrix.
#' @examples
#' m <- poly(1:10, degree = 4)
#'
#' # Difference between min and max values of first column is 10
#' scaled <- poly_rescale(m, scale_width = 10)
#' scaled
#'
#' # Rescaled values are still orthogonal
#' zapsmall(cor(scaled))
poly_rescale <- function(x, scale_width = 1) {
  d1 <- x[, 1]
  current_width <- max(d1) - min(d1)

  if (is.null(scale_width)) {
    scale_width <- current_width
  }

  scale_by <- scale_width / current_width
  x <- x * scale_by

  # Confirm new scaling
  new_d1 <- x[, 1]
  new_width <- max(new_d1) - min(new_d1)
  stopifnot(all.equal(new_width, scale_width))

  poly_strip_info(x)
}




# Strip some metadata from a polynomial matrix
poly_strip_info <- function(x) {
  class(x) <- "matrix"
  attr(x, "coefs") <- NULL
  x
}
