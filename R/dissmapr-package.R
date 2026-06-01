#' @keywords internal
#' @importFrom rlang .data
#' @importFrom dplyr %>%
#' @importFrom grDevices colorRampPalette
#' @importFrom stats na.omit quantile
#' @importFrom utils combn
"_PACKAGE"

## Suppress R CMD check NOTEs for non-standard evaluation variables
utils::globalVariables(c(

  # data.table / dplyr NSE symbols
  "..sp_cols", ":=", "value", "species", "site_id", "x", "y",
  "site_from", "site_to", "grid_id", "orig_x", "orig_y",
  "obs_sum", "spp_rich", "centroid_lon", "centroid_lat", "mapsheet",
  "pred_zetaExp", "zOrder"
))
