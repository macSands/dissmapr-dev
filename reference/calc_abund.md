# Calculate species abundance

If `vec_to` is `NULL`, returns total abundance at a site. Otherwise
returns the absolute difference in total abundance between two vectors.

## Usage

``` r
calc_abund(vec_from, vec_to = NULL)
```

## Arguments

- vec_from:

  Numeric vector of counts (site A).

- vec_to:

  Optional numeric vector of counts (site B).

## Value

Numeric scalar.

## Examples

``` r
calc_abund(c(3, 0, 1, 2, 0))
#> [1] 6
calc_abund(c(3, 0, 1, 2, 0), c(0, 4, 1, 0, 5))
#> [1] 4
```
