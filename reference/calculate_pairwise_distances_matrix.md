# Pairwise distance matrix (long format)

Computes pairwise geographic distances between sites from lon/lat
columns and returns a long table of site pairs and distances.

## Usage

``` r
calculate_pairwise_distances_matrix(
  data,
  id_col = "grid_id",
  x_col = "x",
  y_col = "y",
  distance_fun = geosphere::distGeo,
  units = c("km", "m"),
  drop_self = TRUE,
  triangle = c("all", "upper", "lower")
)
```

## Arguments

- data:

  A data frame containing site IDs and coordinates.

- id_col:

  Name of the site ID column (default: "grid_id").

- x_col:

  Name of the longitude column (default: "x").

- y_col:

  Name of the latitude column (default: "y").

- distance_fun:

  Distance function passed to
  [`geosphere::distm()`](https://rdrr.io/pkg/geosphere/man/distm.html).
  Defaults to
  [`geosphere::distGeo()`](https://rdrr.io/pkg/geosphere/man/distGeo.html).

- units:

  Distance units: "km" (default) or "m".

- drop_self:

  Logical; drop site-to-itself rows (default TRUE).

- triangle:

  Which pairs to return: "all" (default), "upper", or "lower".

## Value

A tibble with columns: site_from, site_to, value.

## Examples

``` r
library(tibble)
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union

# Simulated example so this runs as-is:
set.seed(1)
my_sites_df <- tibble(
  grid_id       = sprintf("S%02d", 1:10),
  centroid_lon  = runif(10, 18, 32),
  centroid_lat  = runif(10, -35, -22)
)

# Pairwise distances (km) using custom coord columns:
dist_df <- calculate_pairwise_distances_matrix(
  data  = my_sites_df,
  x_col = "centroid_lon",
  y_col = "centroid_lat"
)
dist_df %>% slice_head(n = 6)
#> # A tibble: 6 × 3
#>   site_from site_to value
#>   <chr>     <chr>   <dbl>
#> 1 S02       S01      147.
#> 2 S03       S01      809.
#> 3 S04       S01      895.
#> 4 S05       S01      817.
#> 5 S06       S01      949.
#> 6 S07       S01     1183.

# Unique pairs only (upper triangle), meters:
dist_unique <- calculate_pairwise_distances_matrix(
  data     = my_sites_df,
  x_col    = "centroid_lon",
  y_col    = "centroid_lat",
  units    = "m",
  triangle = "upper"
)
dist_unique %>% slice_head(n = 6)
#> # A tibble: 6 × 3
#>   site_from site_to   value
#>   <chr>     <chr>     <dbl>
#> 1 S01       S02     146520.
#> 2 S01       S03     809455.
#> 3 S02       S03     784411.
#> 4 S01       S04     895101.
#> 5 S02       S04     773975.
#> 6 S03       S04     635124.
```
