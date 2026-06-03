# Calculate mutual information (plugin estimator)

Computes mutual information between two vectors using
[`entropy::mi.plugin()`](https://rdrr.io/pkg/entropy/man/mi.plugin.html)
on the joint frequency table. For continuous variables, consider binning
first.

## Usage

``` r
calc_mutual_info(vec_from, vec_to = NULL)
```

## Arguments

- vec_from:

  Vector (numeric, integer, factor, character).

- vec_to:

  Vector (numeric, integer, factor, character). If `NULL`, returns
  `NA_real_`.

## Value

Non-negative numeric scalar, or `NA_real_`.

## Examples

``` r
if (FALSE) { # \dontrun{
calc_mutual_info(c(1, 2, 1, 2, 1), c(1, 1, 2, 2, 1))
} # }
```
