# Calculate Gower dissimilarity (two vectors)

Uses [`cluster::daisy()`](https://rdrr.io/pkg/cluster/man/daisy.html)
with metric = "gower".

## Usage

``` r
calc_gower(vec_from, vec_to = NULL)
```

## Arguments

- vec_from:

  Numeric vector (site A).

- vec_to:

  Numeric vector (site B). If `NULL`, returns `NA_real_`.

## Value

Numeric scalar in the range 0 to 1 or `NA_real_`.

## Examples

``` r
calc_gower(c(3, 0, 1, 2), c(0, 4, 1, 5))
#> Error in calc_gower(c(3, 0, 1, 2), c(0, 4, 1, 5)): could not find function "calc_gower"
calc_gower(c(1, 2, 3), NULL)
#> Error in calc_gower(c(1, 2, 3), NULL): could not find function "calc_gower"
```
