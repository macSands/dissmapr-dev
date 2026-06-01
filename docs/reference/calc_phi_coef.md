# Calculate phi coefficient (presence/absence association)

Computes the phi coefficient between two presence/absence vectors
derived from counts (\>0).

## Usage

``` r
calc_phi_coef(vec_from, vec_to = NULL)
```

## Arguments

- vec_from:

  Numeric vector of counts (site A).

- vec_to:

  Numeric vector of counts (site B). If `NULL`, returns `NA_real_`.

## Value

Numeric scalar in the range -1 to 1, or `NA_real_` if undefined.

## Examples

``` r
calc_phi_coef(c(1, 0, 1, 1, 0), c(1, 1, 0, 1, 0))
#> Error in calc_phi_coef(c(1, 0, 1, 1, 0), c(1, 1, 0, 1, 0)): could not find function "calc_phi_coef"
calc_phi_coef(c(1, 0, 1), NULL)
#> Error in calc_phi_coef(c(1, 0, 1), NULL): could not find function "calc_phi_coef"
```
