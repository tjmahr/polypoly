
<!-- README.md is generated from README.Rmd. Please edit that file -->
polypoly
========

The goal of polypoly is to provide helper functions for polynomials created by `poly()`.

The name "polypoly" has no special significance It's just something catchy and related to `poly()`.

Installation
------------

You can install polypoly from github with:

``` r
# install.packages("devtools")
devtools::install_github("tjmahr/polypoly")
```

Example
-------

This package provides a tidying function `poly_melt()` and plotting function `poly_plot()`.

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
poly_plot(poly_mat)
```

![](fig/README-example-1.png)

We can also plot raw polynomials, but that display is less useful because the x-axis corresponds to the row number of polynomial matrix.

``` r
poly_raw_mat  <- poly(-10:10, degree = 3, raw = TRUE)
poly_plot(poly_raw_mat)
```

![](fig/README-raw-example-1.png)

Resources
---------

If you searched for help on `poly()`, see also:

-   [What does the R function `poly()` really do?](https://stackoverflow.com/questions/19484053/what-does-the-r-function-poly-really-do)
