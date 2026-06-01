# Calculate species richness

Counts the number of non-zero species in a site vector. If `vec_to` is
provided, returns the absolute difference in richness between the two
vectors.

## Usage

``` r
calc_richness(vec_from, vec_to = NULL)
```

## Arguments

- vec_from:

  Numeric vector of counts (one site).

- vec_to:

  Optional numeric vector of counts (another site).

## Value

Numeric scalar.

## Examples

``` r
calc_richness(c(3, 0, 1, 2, 0))
#> Error in calc_richness(c(3, 0, 1, 2, 0)): could not find function "calc_richness"
calc_richness(c(3, 0, 1, 2, 0), c(0, 4, 1, 0, 5))
#> Error in calc_richness(c(3, 0, 1, 2, 0), c(0, 4, 1, 0, 5)): could not find function "calc_richness"
```
