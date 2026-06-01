# Retrieve, crop, resample, and link environmental rasters to sampling sites

`get_enviro_data()` automates six steps:

1.  **AOI build** - buffers the convex hull of all input points.

2.  **Raster acquisition** - downloads or loads a multi-layer stack
    (WorldClim, SoilGrids, footprint, population, or user-supplied).

3.  **Cropping** - trims the stack to the buffered AOI.

4.  **Optional resampling** - resamples the cropped stack to a
    user-defined grid resolution.

5.  **Extraction & gap fill** - pulls raster values at each site and
    linearly interpolates isolated NAs.

6.  **Assembly** - returns a tidy *site x environment* table plus the
    cropped (and resampled) raster and an `sf` layer of sites.

## Usage

``` r
get_enviro_data(
  data,
  buffer_km = 10,
  source = "geodata",
  var = "bio",
  res = 2.5,
  grid_r = NULL,
  path = "data/",
  year = NULL,
  depth = NULL,
  stat = "mean",
  model = NULL,
  ssp = NULL,
  time = NULL,
  sp_cols = NULL,
  ext_cols = NULL
)
```

## Arguments

- data:

  Data frame of spatial points; must include lon/lat columns such as
  `"x","y"` or `"centroid_lon","centroid_lat"`.

- buffer_km:

  Buffer width (km) for the AOI. Default 10.

- source:

  `"geodata"` (default) to fetch layers via **geodata** or `"local"` to
  supply a local `SpatRaster` or file path.

- var:

  Raster product to download (see details) or ignored when
  `source = "local"`.

- res:

  Resolution (arc-min) for WorldClim/WorldPop layers (geodata).

- grid_r:

  Optional grid resolution (in same CRS units) to which the cropped
  raster is resampled before extraction. If `NULL`, no resampling is
  performed.

- path:

  Cache folder for downloaded rasters (created if absent).

- year:

  Optional year for time-stamped products (human footprint, population,
  CMIP6, etc.).

- depth:

  Soil depth argument passed to
  [`geodata::soil_world()`](https://rdrr.io/pkg/geodata/man/soil_grids.html).

- stat:

  Statistic argument passed to
  [`geodata::soil_world()`](https://rdrr.io/pkg/geodata/man/soil_grids.html)
  (default `"mean"`).

- model:

  Optional climate model name for CMIP6 projections.

- ssp:

  Optional Shared Socioeconomic Pathway for CMIP6 projections.

- time:

  Optional time period for CMIP6 projections.

- sp_cols:

  **Columns to drop** from the final table (e.g. a large species
  matrix). Accepts names or numeric indices *relative to `data`*.

- ext_cols:

  **Columns to append** verbatim (e.g. `"obs_sum","spp_rich"`).

## Value

A list with

- `env_rast` `SpatRaster` - cropped (and optionally resampled)
  environmental stack

- `sites_sf` `sf` POINT layer (WGS-84) of the input sites

- `env_df` Tibble with site ID, coordinates, every raster variable, plus
  any columns requested in `ext_cols`

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve WorldClim bioclimatic variables for a set of sites
sites <- data.frame(
  site_id = 1:5,
  centroid_lon = c(25, 26, 27, 28, 29),
  centroid_lat = c(-30, -31, -32, -33, -34)
)
env <- get_enviro_data(sites, var = "bio", res = 10, buffer_km = 50)
head(env$env_df)
} # }
```
