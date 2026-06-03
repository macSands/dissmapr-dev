# Calculate distance between sites in a coordinate table

Convenience wrapper that looks up coordinates in `df` and computes
Haversine distance(s) in **meters**.

## Usage

``` r
calc_distance(df, site_col, vec_from, vec_to = NULL, coord_cols = c("x", "y"))
```

## Arguments

- df:

  Data frame containing site IDs and coordinates.

- site_col:

  Column name in `df` containing site IDs.

- vec_from:

  Single site ID present in `df[[site_col]]`.

- vec_to:

  Optional vector of destination site IDs.

- coord_cols:

  Coordinate columns in `df` (default c("x","y") where x=lon, y=lat).

## Value

Numeric distance in meters (scalar).

## Details

- If `vec_to` is `NULL` (order = 1), returns 0.

- If `vec_to` is length 1, returns a single pairwise distance.

- If `vec_to` is length \> 1, returns the **sum** of distances from
  `vec_from` to each site in `vec_to` (useful as a simple multi-site
  aggregation).

## Examples

``` r
sites <- data.frame(site = c("A", "B", "C"), x = c(18.4, 28.0, 25.7), y = c(-33.9, -26.2, -29.1))
calc_distance(sites, "site", "A", "B")
#> [1] 1259885
calc_distance(sites, "site", "A", NULL)
#> [1] 0
```
