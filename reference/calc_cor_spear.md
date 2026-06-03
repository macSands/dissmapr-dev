# Calculate Spearman correlation (abundance association)

Calculate Spearman correlation (abundance association)

## Usage

``` r
calc_cor_spear(vec_from, vec_to = NULL)
```

## Arguments

- vec_from:

  Numeric vector (site A).

- vec_to:

  Numeric vector (site B). If `NULL`, returns `NA_real_`.

## Value

Numeric scalar correlation, or `NA_real_`.

## Examples

``` r
calc_cor_spear(c(1, 3, 5, 7, 9), c(2, 4, 6, 8, 10))
#> [1] 1
calc_cor_spear(c(1, 3, 5), NULL)
#> [1] NA
```
