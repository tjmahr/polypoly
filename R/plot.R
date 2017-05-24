
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
#' @param by_observation whether the plot's x axis should be the observation/row
#'   number (`TRUE`, the default), or whether it should be the degree-1 terms
#'   (`FALSE`)
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


#' Add orthogonal polynomial columns to a dataframe
#' @param .data a dataframe
#' @param .col a bare column name
#' @param degree number of polynomial terms to add to the dataframe
#' @param prefix prefix for the names to add to the dataframe. default is the
#'   name of `.col`.
#' @param scale_width optionally rescale the dataframe using [poly_rescale()].
#'   default is not to performa any rescaling.
#' @return the dataframe with additional columns of orthogonal polynomial terms
#'   of `.col`
#' @export
poly_add_columns <- function(.data, .col, degree = 1, prefix = NULL, scale_width = NULL) {
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

  # Name the columns
  if (is.null(prefix)) {
    prefix <- .col_name
  }

  names <- paste0(prefix, seq_len(degree))

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
  tibble::add_column(.data, rlang::UQS(cols_to_add))
}


#' Rescale the range of a polynomial matrix
#'
#' @param x a matrix created by [stats::poly()]
#' @param scale_width the desired range (max - min) for the first column of the matrix
#' @return the rescale polynomial matrix (as a plain matrix with attributes removed)
#' @export
#' @details This function strips away the `poly` class and some of the
#'   attributes of the matrix. This is because those attributes no longer
#'   describe the transformed matrix.
poly_rescale <- function(x, scale_width = 1) {
  d1 <- x[, 1]
  current_width <- max(d1) - min(d1)

  if (is.null(scale_width)) {
    scale_width <- current_width
  }

  scale_by <- scale_width / current_width
  x <- x * scale_by

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
