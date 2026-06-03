# Raster-based Clustering and Interpolation of Bioregional Data

`map_bioreg` performs clustering (k-means, PAM, hierarchical, GMM) on
spatial point data, computes modal or user-specified interpolation
(none, nearest-neighbour, TPS), aligns cluster labels by overlap, and
returns both data tables and raster stacks.

## Usage

``` r
map_bioreg(
  data,
  scale_cols,
  method = c("kmeans", "pam", "hclust", "gmm", "all"),
  k_override = NULL,
  x_col = "x",
  y_col = "y",
  interpolate = c("none", "nn", "tps", "all"),
  res = 0.5,
  crs = "EPSG:4326",
  plot = TRUE,
  bndy_fc = NULL
)
```

## Arguments

- data:

  A single data.frame of point observations or a named list of such
  data.frames (e.g. different scenarios). Each data.frame must contain
  coordinate columns and variables to scale.

- scale_cols:

  Character vector of column names in `data` to standardize before
  clustering.

- method:

  Character vector of clustering methods to apply; choices of "kmeans",
  "pam", "hclust", "gmm", or "all".

- k_override:

  Integer. If provided, fixes the number of clusters rather than
  computing via silhouette.

- x_col, y_col:

  Strings giving the names of the longitude (x) and latitude (y) columns
  for spatial mapping.

- interpolate:

  One of "none", "nn", "tps", or "all"; selects which interpolation(s)
  to compute.

- res:

  Numeric resolution of output rasters (in the same units as
  coordinates).

- crs:

  Coordinate reference system string for raster outputs (e.g.
  "EPSG:4326").

- plot:

  Logical; if TRUE, displays spatial tile plots of clusters/modes.

- bndy_fc:

  Optional `sf` or `SpatVector` polygon to overlay.

## Value

A named list with elements:

- none, nn, tps:

  Named lists of Terra SpatRaster stacks for each scenario, each layer
  labelled "*algn*".

- table:

  A data.frame: original points, cluster columns, modal label, aligned
  labels.

- plots:

  List of individual ggplot objects when `plot = TRUE`.

- combined_plot:

  A single combined patchwork plot when `plot = TRUE`, `NULL` otherwise.
  Call [`print()`](https://rdrr.io/r/base/print.html) on this object to
  display it.

- methods:

  Character vector of methods actually computed.

## Details

Internally, the function standardizes `scale_cols`, runs requested
clustering(s), computes a modal consensus label, and then aligns each
algorithm's cluster numbers to the k-means reference by maximal cell
overlap. Three interpolation functions (`fill_none_full`,
`fill_nn_full`, `fill_tps_full`) generate rasters of raw and aligned
labels. Progress bars display per scenario.

## Examples

``` r
if (requireNamespace("terra", quietly = TRUE)) {
  # simulate a single data.frame
  set.seed(42)
  df <- data.frame(
    centroid_lon = runif(100, 16, 33),
    centroid_lat = runif(100, -35, -22),
    pred_zetaExp = rnorm(100)
  )

  # single scenario clustering (use a method that does NOT require optional packages)
  out1 <- map_bioreg(
    data       = df,
    scale_cols  = c("pred_zetaExp", "centroid_lon", "centroid_lat"),
    method      = "kmeans",
    k_override  = 4,
    x_col       = "centroid_lon",
    y_col       = "centroid_lat",
    interpolate = "none",
    plot        = FALSE
  )
  out1$methods

  # simulate multiple scenarios
  df2 <- df
  df2$centroid_lon <- df2$centroid_lon + 5
  scen_list <- list(current = df, future = df2)

  out2 <- map_bioreg(
    data       = scen_list,
    scale_cols  = c("pred_zetaExp", "centroid_lon", "centroid_lat"),
    method      = "kmeans",
    k_override  = 3,
    x_col       = "centroid_lon",
    y_col       = "centroid_lat",
    interpolate = "none",
    plot        = FALSE
  )
  out2$methods
}
#> [1] "kmeans"

# Optional GMM clustering requires the 'mclust' package:
# if (requireNamespace("mclust", quietly = TRUE) && requireNamespace("terra", quietly = TRUE)) {
#   out_gmm <- map_bioreg(df, c("pred_zetaExp", "centroid_lon", "centroid_lat"), method = "gmm",
#                         k_override = 4, x_col = "centroid_lon", y_col = "centroid_lat",
#                         interpolate = "none", plot = FALSE)
# }
```
