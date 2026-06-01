# Calculate Pearson correlation (abundance association)

Calculate Pearson correlation (abundance association)

## Usage

``` r
calc_cor_pears(vec_from, vec_to = NULL)
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
calc_cor_pears(c(1, 3, 5, 7, 9), c(2, 4, 6, 8, 10))
#> Error in calc_cor_pears(c(1, 3, 5, 7, 9), c(2, 4, 6, 8, 10)): could not find function "calc_cor_pears"
calc_cor_pears(c(1, 3, 5), NULL)
#> Error in calc_cor_pears(c(1, 3, 5), NULL): could not find function "calc_cor_pears"
```
