
<!-- README.md is generated from README.Rmd. Please edit that file -->
![](fig/README-logo-1.png)

polypoly
========

Helper functions for polynomials created by `poly()`.

Installation
------------

You can install polypoly from github with:

``` r
# install.packages("devtools")
devtools::install_github("tjmahr/polypoly")
```

Examples
--------

### Tidying

This package provides a tidying function `poly_melt()`.

``` r
library(polypoly)
xs <- 1:40
poly_mat <- poly(xs, degree = 5)
poly_melt(poly_mat)
#> # A tibble: 200 x 3
#>    observation degree      value
#>          <int>  <chr>      <dbl>
#>  1           1      1 -0.2670982
#>  2           2      1 -0.2534009
#>  3           3      1 -0.2397035
#>  4           4      1 -0.2260062
#>  5           5      1 -0.2123088
#>  6           6      1 -0.1986115
#>  7           7      1 -0.1849142
#>  8           8      1 -0.1712168
#>  9           9      1 -0.1575195
#> 10          10      1 -0.1438221
#> # ... with 190 more rows
```

### Plotting

Plot a matrix with `poly_plot()`.

``` r
poly_plot(poly_mat)
```

![](fig/README-example-1.png)

We can also plot raw polynomials, but that display is less useful because the *x*-axis corresponds to the row number of polynomial matrix.

``` r
poly_raw_mat  <- poly(-10:10, degree = 3, raw = TRUE)
poly_plot(poly_raw_mat)
```

![](fig/README-raw-example-1.png)

We can make the units clearer by using `by_observation = FALSE` so that the *x*-axis corresponds to the first column of the polynomial matrix.

``` r
poly_raw_mat  <- poly(-10:10, degree = 3, raw = TRUE)
poly_plot(poly_raw_mat, by_observation = FALSE)
```

![](fig/README-raw-by-degree1-1.png)

### Rescaling a matrix

The ranges of the terms created by `poly()` are sensitive to repeated values.

``` r
p1 <- poly(0:9, degree = 2)
p2 <- poly(rep(0:9, 18), degree = 2)

col_range <- function(matrix) {
  apply(matrix, 2, function(xs) max(xs) - min(xs))  
}

col_range(p1)
#>         1         2 
#> 0.9908674 0.8703883
col_range(p2)
#>         1         2 
#> 0.2335497 0.2051525
```

Thus, two models fit with `y ~ poly(x, 3)` will not have comparable coefficients when the number of rows changes, even if the unique values of `x` did not change!

`poly_rescale()` adjusts the values in the polynomial matrix so that the linear component has a specified range. The other terms are scaled by the same factor.

``` r
col_range(poly_rescale(p1, scale_width = 1))
#>         1         2 
#> 1.0000000 0.8784105
col_range(poly_rescale(p2, scale_width = 1))
#>         1         2 
#> 1.0000000 0.8784105

poly_plot(poly_rescale(p2, scale_width = 1), by_observation = FALSE)
```

![](fig/README-rescaled-1.png)

### Adding columns to a dataframe

`poly_add_columns()` adds orthogonal polynomial transformations of a predictor variable to a dataframe.

Here's how we could add polynomials to the `sleepstudy` dataset.

``` r
df <- tibble::as_tibble(lme4::sleepstudy)
print(df)
#> # A tibble: 180 x 3
#>    Reaction  Days Subject
#>       <dbl> <dbl>  <fctr>
#>  1 249.5600     0     308
#>  2 258.7047     1     308
#>  3 250.8006     2     308
#>  4 321.4398     3     308
#>  5 356.8519     4     308
#>  6 414.6901     5     308
#>  7 382.2038     6     308
#>  8 290.1486     7     308
#>  9 430.5853     8     308
#> 10 466.3535     9     308
#> # ... with 170 more rows

poly_add_columns(df, Days, degree = 3)
#> # A tibble: 180 x 6
#>    Reaction  Days Subject       Days1       Days2      Days3
#>       <dbl> <dbl>  <fctr>       <dbl>       <dbl>      <dbl>
#>  1 249.5600     0     308 -0.49543369  0.52223297 -0.4534252
#>  2 258.7047     1     308 -0.38533732  0.17407766  0.1511417
#>  3 250.8006     2     308 -0.27524094 -0.08703883  0.3778543
#>  4 321.4398     3     308 -0.16514456 -0.26111648  0.3346710
#>  5 356.8519     4     308 -0.05504819 -0.34815531  0.1295501
#>  6 414.6901     5     308  0.05504819 -0.34815531 -0.1295501
#>  7 382.2038     6     308  0.16514456 -0.26111648 -0.3346710
#>  8 290.1486     7     308  0.27524094 -0.08703883 -0.3778543
#>  9 430.5853     8     308  0.38533732  0.17407766 -0.1511417
#> 10 466.3535     9     308  0.49543369  0.52223297  0.4534252
#> # ... with 170 more rows
```

We can optionally customize the column names and rescale the polynomial terms.

``` r
poly_add_columns(df, Days, degree = 3, prefix = "poly_", scale_width = 1)
#> # A tibble: 180 x 6
#>    Reaction  Days Subject      poly_1      poly_2     poly_3
#>       <dbl> <dbl>  <fctr>       <dbl>       <dbl>      <dbl>
#>  1 249.5600     0     308 -0.50000000  0.52704628 -0.4576043
#>  2 258.7047     1     308 -0.38888889  0.17568209  0.1525348
#>  3 250.8006     2     308 -0.27777778 -0.08784105  0.3813369
#>  4 321.4398     3     308 -0.16666667 -0.26352314  0.3377556
#>  5 356.8519     4     308 -0.05555556 -0.35136418  0.1307441
#>  6 414.6901     5     308  0.05555556 -0.35136418 -0.1307441
#>  7 382.2038     6     308  0.16666667 -0.26352314 -0.3377556
#>  8 290.1486     7     308  0.27777778 -0.08784105 -0.3813369
#>  9 430.5853     8     308  0.38888889  0.17568209 -0.1525348
#> 10 466.3535     9     308  0.50000000  0.52704628  0.4576043
#> # ... with 170 more rows
```

Resources
---------

If you searched for help on `poly()`, see also:

-   [What does the R function `poly()` really do?](https://stackoverflow.com/questions/19484053/what-does-the-r-function-poly-really-do)
-   [Source code for the poly function](https://github.com/wch/r-source/blob/af7f52f70101960861e5d995d3a4bec010bc89e6/src/library/stats/R/contr.poly.R#L85)
