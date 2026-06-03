# Calculate geographic distance via Haversine formula

Computes the Haversine distance in **meters** between two coordinate
pairs. If `vec_to` is `NULL` (e.g., order = 1), returns 0.

## Usage

``` r
calc_geodist(
  vec_from,
  vec_to = NULL,
  coord_cols = c("centroid_lon", "centroid_lat")
)
```

## Arguments

- vec_from:

  Numeric vector of length 2, or a named numeric vector containing
  coordinates (e.g. c(lon = ..., lat = ...)).

- vec_to:

  Optional numeric vector of length 2 (destination coordinates). If
  `NULL`, returns 0.

- coord_cols:

  Character vector of length 2 giving the names of the longitude and
  latitude elements in `vec_from`/`vec_to` when those are named vectors.
  Defaults to `c("centroid_lon", "centroid_lat")`.

## Value

Numeric distance in meters (scalar).

## Examples

``` r
calc_geodist(c(18.4, -33.9), c(28.0, -26.2))
#> [1] 1259885
calc_geodist(c(centroid_lon = 18.4, centroid_lat = -33.9), NULL)
#> [1] 0
```
