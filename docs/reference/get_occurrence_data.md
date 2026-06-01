# Import and harmonise biodiversity-occurrence data

`get_occurrence_data()` reads occurrence records from a **local CSV/file
path**, an **in-memory `data.frame`**, or a **GBIF download (ZIP)** and
returns a tidy data frame in either **long** (one row = one record) or
**wide** (one row = one site, one column = one species) form.

## Usage

``` r
get_occurrence_data(
  data = NULL,
  source_type = c("local_csv", "data_frame", "gbif"),
  gbif_zip_url = NULL,
  download_dir = tempdir(),
  sep = ",",
  site_id_col = NULL,
  x_col = NULL,
  y_col = NULL,
  sp_name_col = NULL,
  pa_col = NULL,
  abund_col = NULL,
  species_cols = NULL
)
```

## Arguments

- data:

  File path (when `source_type = "local_csv"`), an in-memory
  `data.frame` (`"data_frame"`), or `NULL` (`"gbif"`).

- source_type:

  `"local_csv"`, `"data_frame"`, or `"gbif"`.

- gbif_zip_url:

  URL to a GBIF download ZIP (required when `source_type = "gbif"`).

- download_dir:

  Folder to save the ZIP/extracted file (default:
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html)).

- sep:

  Field separator for CSVs (default `","`).

- site_id_col, x_col, y_col, sp_name_col, pa_col, abund_col:

  Optional custom column names.

- species_cols:

  **Optional** numeric or character vector specifying the species
  columns in a wide input (e.g. `4:11` or `c("Sp1","Sp2")`). Overrides
  the default `"sp_*"` detection.

## Value

A `data.frame`:

- Long format:

  Columns `site_id`, `x`, `y`, `sp_name`, plus `pa` *or* `abund`.

- Wide - long:

  Same columns after stacking the specified or auto-detected species
  columns.

## Details

Column names are auto-detected from common patterns (`"site_id"`, `"x"`,
`"y"`, `"sp_name"`, `"pa"` or `"abund"`). Supply `*_col` arguments
**only** when your data use different names.

For wide data the helper normally looks for columns that start with
`"sp_"`. Set `species_cols` to a numeric range (e.g. `4:11`) or a
character vector of column names when the species columns do **not**
follow the `"sp_*"` convention.

## Workflow

1.  **Read** the data from `source_type`.

2.  **Detect / insert** compulsory columns (site, coords, species,
    value).

3.  **Validate** coordinates (-180 \<= lon \<= 180, -90 \<= lat \<= 90).

4.  **Return**

    - a long table (`site_id`, `x`, `y`, `sp_name`, `pa|abund`) when
      species name + value columns are present; or

    - a long table reshaped from wide species columns.

## See also

[`tidyr::pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html)
used internally.

## Examples

``` r
# 1. Local CSV example -----------------------------------------------
tmp <- tempfile(fileext = ".csv")
df_local <- data.frame(
  site_id = 1:10,
  x = runif(10), y = runif(10),
  sp_name = c("plant1", "plant2","plant3", "plant4","plant5", "plant1",
  "plant2","plant3", "plant4","plant5"),
  abun = sample(0:20, size = 10, replace = TRUE)
)
write.csv(df_local, tmp, row.names = FALSE)
local_test = get_occurrence_data(data = tmp, source_type = "local_csv", sep = ",")

# 2. Existing wide-format data.frame -----------------------------------------------
sp_mat <- stats::xtabs(abun ~ site_id + sp_name, data = df_local)
sp_df  <- as.data.frame.matrix(sp_mat)
sites  <- unique(df_local[, c("site_id", "x", "y")])
df_wide <- cbind(sites, sp_df)

wide_test <- get_occurrence_data(
  data         = df_wide,
  source_type  = "data_frame",
  species_cols = 4:ncol(df_wide)
)

# 3. Custom names ----------------------------------------------------------
if (FALSE) { # \dontrun{
custom_df <- df_local
names(custom_df)[1:5] <- c("plot_id", "lon", "lat", "taxon", "presence")
occ_long2 <- get_occurrence_data(
  data           = custom_df,
  source_type    = "data_frame",
  site_id_col    = "plot_id",
  x_col          = "lon",
  y_col          = "lat",
  sp_name_col    = "taxon",
  pa_col         = "presence"
)
head(occ_long2)
} # }

# 4. GBIF download (requires internet) -----------------------------------------------
if (FALSE) { # \dontrun{
gbif_test = get_occurrence_data(
  source_type   = "gbif",
  gbif_zip_url  = "https://api.gbif.org/v1/occurrence/download/request/0038969-240906103802322.zip"
)
} # }
```
