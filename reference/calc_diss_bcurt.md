# Calculate Bray-Curtis dissimilarity (abundance)

Uses
[`vegan::vegdist()`](https://vegandevs.github.io/vegan/reference/vegdist.html)
on a 2-row matrix.

## Usage

``` r
calc_diss_bcurt(vec_from, vec_to = NULL)
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
if (FALSE) { # \dontrun{
calc_diss_bcurt(c(3, 0, 1, 2), c(0, 4, 1, 5))
} # }
```
