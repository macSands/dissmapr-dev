# Calculate Gower dissimilarity (orderwise alias)

Kept for backward compatibility; same behaviour as
[`calc_gower()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_gower.md).

## Usage

``` r
calc_orderwise_gower(vec_from, vec_to = NULL)
```

## Arguments

- vec_from:

  Numeric vector (site A).

- vec_to:

  Optional numeric vector (site B).

## Value

Numeric scalar in the range 0 to 1 or `NA_real_`.

## Examples

``` r
calc_orderwise_gower(c(3, 0, 1, 2), c(0, 4, 1, 5))
#> Error in calc_orderwise_gower(c(3, 0, 1, 2), c(0, 4, 1, 5)): could not find function "calc_orderwise_gower"
calc_orderwise_gower(c(1, 2, 3), NULL)
#> Error in calc_orderwise_gower(c(1, 2, 3), NULL): could not find function "calc_orderwise_gower"
```
