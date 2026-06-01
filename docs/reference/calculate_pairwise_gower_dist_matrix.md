# Pairwise Gower dissimilarity matrix (long format)

Computes pairwise Gower dissimilarities between rows of `df` using
columns in `sp_cols`. Returns long format with site IDs.

## Usage

``` r
calculate_pairwise_gower_dist_matrix(
  df,
  sp_cols,
  id_col = "grid_id",
  triangle = c("all", "upper", "lower"),
  drop_self = TRUE
)
```

## Arguments

- df:

  Data frame containing a site identifier and species/trait columns.

- sp_cols:

  Character vector of numeric (or mixed) columns to use in Gower.

- id_col:

  Site ID column name (default "grid_id").

- triangle:

  Which pairs to return: "all" (default), "upper", or "lower".

- drop_self:

  Drop self-pairs (default TRUE).

## Value

A tibble with columns site_from, site_to, value.
