## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE
)

## -----------------------------------------------------------------------------
# orthogonal polynomials
m <- poly(1:6, degree = 3, simple = TRUE)
m

# the terms are uncorrelated. that's why they are "orthogonal".
zapsmall(cor(m))

# raw polynomials
m <- poly(1:6, degree = 3, simple = TRUE, raw = TRUE)
m

# raw polynomials are highly correlated.
round(cor(m), 2)

## -----------------------------------------------------------------------------
library(polypoly)
xs <- 1:40
poly_mat <- poly(xs, degree = 5)
poly_melt(poly_mat)

## ----example, fig.width = 5, fig.height = 3-----------------------------------
poly_plot(poly_mat)

## ----raw-example, fig.width = 5, fig.height = 3-------------------------------
poly_raw_mat <- poly(-10:10, degree = 3, raw = TRUE)
poly_plot(poly_raw_mat)

## ----raw-by-degree1,  fig.width = 5, fig.height = 3---------------------------
poly_plot(poly_raw_mat, by_observation = FALSE)

## ----sum, fig.width = 5, fig.height = 3---------------------------------------
library(ggplot2)
poly_plot(poly_mat) + 
  stat_summary(
    aes(color = "sum"), 
    fun = "sum", 
    geom = "line", 
    size = 1
  ) + 
  theme_minimal()

## -----------------------------------------------------------------------------
poly_plot_data(poly_mat, by_observation = FALSE)

## -----------------------------------------------------------------------------
# For each column in a matrix, return difference between max and min values
col_range <- function(matrix) {
  apply(matrix, 2, function(xs) max(xs) - min(xs))  
}

p1 <- poly(0:9, degree = 2)
p2 <- poly(rep(0:9, 18), degree = 2)

col_range(p1)
col_range(p2)

## ----rescaled,  fig.width = 5, fig.height = 3---------------------------------
col_range(poly_rescale(p1, scale_width = 1))
col_range(poly_rescale(p2, scale_width = 1))

poly_plot(poly_rescale(p2, scale_width = 1), by_observation = FALSE)

## -----------------------------------------------------------------------------
df <- tibble::as_tibble(lme4::sleepstudy)
print(df)

poly_add_columns(df, Days, degree = 3)

## -----------------------------------------------------------------------------
poly_add_columns(df, Days, degree = 3, prefix = "poly_", scale_width = 1)

## ----sleepstudy, fig.width = 5, fig.height = 3--------------------------------
df <- poly_add_columns(df, Days, degree = 3, scale_width = 1)
zapsmall(cor(df[c("Days1", "Days2", "Days3")]))

## ----splines,  fig.width = 5, fig.height = 3----------------------------------
poly_plot(splines::bs(1:100, 10, intercept = TRUE))
poly_plot(splines::ns(1:100, 10, intercept = FALSE))

## ----trees1, fig.width = 5, fig.height = 3------------------------------------
library(lme4)
df <- tibble::as_tibble(Orange)
df$Tree <- as.character(df$Tree)
df

ggplot(df) + 
  aes(x = age, y = circumference, color = Tree) + 
  geom_line()

## -----------------------------------------------------------------------------
df <- poly_add_columns(Orange, age, 3, scale_width = 1)

model <- lmer(
  scale(circumference) ~ age1 + age2 + age3 + (age1 + age2 + age3 | Tree), 
  data = df
)
summary(model)

## -----------------------------------------------------------------------------
poly_mat <- poly_rescale(poly(df$age, degree = 3), 1)

# Keep only seven rows because there are 7 observations per tree
poly_mat <- poly_mat[1:7, ]

pred_mat <- cbind(constant = 1, poly_mat)
pred_mat

## -----------------------------------------------------------------------------
weighted <- pred_mat %*% diag(fixef(model))
colnames(weighted) <- colnames(pred_mat)

## ----trees-comparison, fig.width = 7, fig.height = 3--------------------------
df_raw <- poly_melt(pred_mat)
df_raw$predictors <- "raw"

df_weighted <- poly_melt(weighted)
df_weighted$predictors <- "weighted"

df_both <- rbind(df_raw, df_weighted)

# Only need the first 7 observations because that is one tree
ggplot(df_both[df_both$observation <= 7, ]) + 
  aes(x = observation, y = value, color = degree) + 
  geom_line() + 
  facet_grid(. ~ predictors) + 
  labs(color = "term")

