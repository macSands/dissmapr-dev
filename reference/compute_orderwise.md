# Compute Order-wise Metrics

This function computes metrics for ecological data across specified
order levels. It supports single-site, pairwise, and higher-order
calculations, and allows for parallel processing for efficiency.

## Usage

``` r
compute_orderwise(
  df,
  func,
  site_col,
  sp_cols = NULL,
  order = 2,
  sample_no = NULL,
  sample_portion = 1,
  parallel = FALSE,
  n_workers = max(1, parallel::detectCores() - 1)
)
```

## Arguments

- df:

  A data frame containing the ecological data.

- func:

  A function to compute metrics. It must accept inputs in the form of
  species vectors or site information depending on the order.

- site_col:

  A character string specifying the column name in `df` representing
  site IDs.

- sp_cols:

  A vector of column names in `df` representing species data (default:
  NULL).

- order:

  An integer or vector of integers specifying the order(s) of
  computation.

  - `1`: Single-site computations.

  - `2`: Pairwise computations.

  - `>= 3`: Higher-order computations.

- sample_no:

  An integer specifying the maximum number of combinations to sample for
  higher-order computations (default: NULL for all combinations).

- sample_portion:

  A numeric value between 0 and 1 indicating the proportion of
  combinations to sample for higher-order computations (default: 1,
  meaning 100%).

- parallel:

  A logical value indicating whether to enable parallel computation
  (default: TRUE).

- n_workers:

  An integer specifying the number of parallel workers to use (default:
  one less than the number of available cores).

## Value

A `data.table` containing the results of computations. Columns include:

- `site_from`: The source site.

- `site_to`: The target site(s) (NA for order = 1).

- `order`: The computation order.

- `value`: The computed metric value.

## Examples

``` r
# Minimal reproducible species-by-site table (one row per site)
block_sp <- data.frame(
  grid_id = letters[1:3],
  sp1 = c(1, 2, 0),
  sp2 = c(0, 1, 2)
)
sp_cols <- c("sp1", "sp2")

# IMPORTANT: keep examples sequential for R CMD check
rich_o12 <- compute_orderwise(
  df       = block_sp,
  func     = calc_richness,
  site_col = "grid_id",
  sp_cols  = sp_cols,
  order    = 1:2,
  parallel = FALSE
)
#> Time elapsed for order 1: 0 minutes and 0.00 seconds
#> Time elapsed for order 2: 0 minutes and 0.00 seconds
#> Total computation time: 0 minutes and 0.00 seconds
head(rich_o12)
#>    site_from site_to order value
#>       <char>  <char> <int> <int>
#> 1:         a    <NA>     1     1
#> 2:         b    <NA>     1     2
#> 3:         c    <NA>     1     1
#> 4:         b       a     2     1
#> 5:         c       a     2     0
#> 6:         a       b     2     1
```
