# Calculate species turnover / beta diversity

Computes turnover as the proportion of unshared species between two
sites (presence/absence implied by counts \> 0).

## Usage

``` r
calc_turnover(vec_from, vec_to = NULL)
```

## Arguments

- vec_from:

  Numeric vector of counts (site A).

- vec_to:

  Numeric vector of counts (site B). If `NULL`, returns `NA_real_`.

## Value

Numeric scalar in the range 0 to 1, or `NA_real_` for order = 1.

## Examples

``` r
calc_turnover(c(3, 0, 1, 2, 0), c(0, 4, 1, 0, 5))
#> Error in calc_turnover(c(3, 0, 1, 2, 0), c(0, 4, 1, 0, 5)): could not find function "calc_turnover"
calc_turnover(c(1, 1, 0), NULL)
#> Error in calc_turnover(c(1, 1, 0), NULL): could not find function "calc_turnover"
```
