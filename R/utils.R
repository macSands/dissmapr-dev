#' Helper functions for compute_orderwise
#' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#'
#' A suite of helper functions to compute ecological indices used by
#' `compute_orderwise()`, including geographic distance, dissimilarity metrics,
#' correlations, and mutual information.
#'
#' These helpers are written to be:
#' - vectorised for the *pairwise* case (two sites/vectors), and
#' - safe for the *order = 1* case (a single site/vector) by returning a sensible
#'   scalar (often 0 or NA) instead of erroring.
#'
#' @name utils
#' @keywords internal
#'
#' @importFrom stats cor complete.cases
#' @importFrom geosphere distHaversine distm distGeo
#' @importFrom cluster daisy
#'
#' @details
#' Additional packages are used via explicit namespace calls:
#' `vegan` (Bray-Curtis), `entropy` (mutual information), `tibble`/`dplyr`
#' (pairwise matrix helpers).
NULL

# ------------------------------------------------------------------------------
# DISTANCE BETWEEN SITES
# ------------------------------------------------------------------------------

#' Calculate geographic distance via Haversine formula
#'
#' Computes the Haversine distance in **meters** between two coordinate pairs.
#' If `vec_to` is `NULL` (e.g., order = 1), returns 0.
#'
#' @param vec_from Numeric vector of length 2, or a named numeric vector containing
#'   coordinates (e.g. c(lon = ..., lat = ...)).
#' @param vec_to Optional numeric vector of length 2 (destination coordinates).
#'   If `NULL`, returns 0.
#' @param coord_cols Character vector of length 2 giving the names of the longitude
#'   and latitude elements in `vec_from`/`vec_to` when those are named vectors.
#'   Defaults to `c("centroid_lon", "centroid_lat")`.
#'
#' @return Numeric distance in meters (scalar).
#' @examples
#' calc_geodist(c(18.4, -33.9), c(28.0, -26.2))
#' calc_geodist(c(centroid_lon = 18.4, centroid_lat = -33.9), NULL)
#' @export
#' @keywords internal
calc_geodist <- function(vec_from, vec_to = NULL,
                           coord_cols = c("centroid_lon", "centroid_lat")) {
  if (is.null(vec_to)) return(0)

  extract_xy <- function(v) {
    if (!is.null(names(v)) && all(coord_cols %in% names(v))) {
      as.numeric(v[coord_cols])
    } else {
      as.numeric(v)
    }
  }

  a <- extract_xy(vec_from)
  b <- extract_xy(vec_to)

  if (length(a) != 2 || length(b) != 2) {
    stop(
      "Both inputs must be coordinate pairs of length 2. If named, names must include: ",
      paste(coord_cols, collapse = ", ")
    )
  }

  geosphere::distHaversine(a, b)
}

#' Calculate distance between sites in a coordinate table
#'
#' Convenience wrapper that looks up coordinates in `df` and computes Haversine
#' distance(s) in **meters**.
#'
#' - If `vec_to` is `NULL` (order = 1), returns 0.
#' - If `vec_to` is length 1, returns a single pairwise distance.
#' - If `vec_to` is length > 1, returns the **sum** of distances from `vec_from`
#'   to each site in `vec_to` (useful as a simple multi-site aggregation).
#'
#' @param df Data frame containing site IDs and coordinates.
#' @param site_col Column name in `df` containing site IDs.
#' @param vec_from Single site ID present in `df[[site_col]]`.
#' @param vec_to Optional vector of destination site IDs.
#' @param coord_cols Coordinate columns in `df` (default c("x","y") where x=lon, y=lat).
#'
#' @return Numeric distance in meters (scalar).
#' @examples
#' sites <- data.frame(site = c("A", "B", "C"), x = c(18.4, 28.0, 25.7), y = c(-33.9, -26.2, -29.1))
#' calc_distance(sites, "site", "A", "B")
#' calc_distance(sites, "site", "A", NULL)
#' @export
#' @keywords internal
calc_distance <- function(df, site_col, vec_from, vec_to = NULL, coord_cols = c("x", "y")) {
  if (!all(c(site_col, coord_cols) %in% names(df))) {
    stop("`df` must contain columns: ", paste(c(site_col, coord_cols), collapse = ", "))
  }

  from_row <- df[df[[site_col]] == vec_from, coord_cols, drop = FALSE]
  if (nrow(from_row) != 1) {
    stop("`vec_from` must match exactly one row in `df[[site_col]]`.")
  }

  if (is.null(vec_to)) return(0)

  to_rows <- df[df[[site_col]] %in% vec_to, coord_cols, drop = FALSE]
  if (nrow(to_rows) == 0) stop("`vec_to` did not match any rows in `df[[site_col]]`.")

  d <- vapply(
    seq_len(nrow(to_rows)),
    function(i) geosphere::distHaversine(from_row, to_rows[i, , drop = FALSE]),
    numeric(1)
  )

  if (length(vec_to) == 1) d[[1]] else sum(d, na.rm = TRUE)
}

#' Pairwise distance matrix (long format)
#'
#' Computes pairwise geographic distances between sites from lon/lat columns and
#' returns a long table of site pairs and distances.
#'
#' @param data A data frame containing site IDs and coordinates.
#' @param id_col Name of the site ID column (default: "grid_id").
#' @param x_col Name of the longitude column (default: "x").
#' @param y_col Name of the latitude  column (default: "y").
#' @param distance_fun Distance function passed to [geosphere::distm()].
#'   Defaults to [geosphere::distGeo()].
#' @param units Distance units: "km" (default) or "m".
#' @param drop_self Logical; drop site-to-itself rows (default TRUE).
#' @param triangle Which pairs to return: "all" (default), "upper", or "lower".
#'
#' @return A tibble with columns: site_from, site_to, value.
#' @export
#' @keywords internal
#'
#' @examples
#' library(tibble)
#' library(dplyr)
#'
#' # Simulated example so this runs as-is:
#' set.seed(1)
#' my_sites_df <- tibble(
#'   grid_id       = sprintf("S%02d", 1:10),
#'   centroid_lon  = runif(10, 18, 32),
#'   centroid_lat  = runif(10, -35, -22)
#' )
#'
#' # Pairwise distances (km) using custom coord columns:
#' dist_df <- calculate_pairwise_distances_matrix(
#'   data  = my_sites_df,
#'   x_col = "centroid_lon",
#'   y_col = "centroid_lat"
#' )
#' dist_df %>% slice_head(n = 6)
#'
#' # Unique pairs only (upper triangle), meters:
#' dist_unique <- calculate_pairwise_distances_matrix(
#'   data     = my_sites_df,
#'   x_col    = "centroid_lon",
#'   y_col    = "centroid_lat",
#'   units    = "m",
#'   triangle = "upper"
#' )
#' dist_unique %>% slice_head(n = 6)
calculate_pairwise_distances_matrix <- function(
    data,
    id_col       = "grid_id",
    x_col        = "x",
    y_col        = "y",
    distance_fun = geosphere::distGeo,
    units        = c("km", "m"),
    drop_self    = TRUE,
    triangle     = c("all", "upper", "lower")
) {
  units    <- match.arg(units)
  triangle <- match.arg(triangle)

  req <- c(id_col, x_col, y_col)
  miss <- setdiff(req, names(data))
  if (length(miss) > 0) stop("`data` is missing required columns: ", paste(miss, collapse = ", "))

  df <- data[, req, drop = FALSE]
  df <- df[stats::complete.cases(df), , drop = FALSE]
  if (nrow(df) < 2) stop("Need at least 2 complete rows to compute pairwise distances.")

  lon <- df[[x_col]]
  lat <- df[[y_col]]
  if (any(lon < -180 | lon > 180)) stop("Longitude values in `", x_col, "` must be in [-180, 180].")
  if (any(lat <  -90 | lat >  90)) stop("Latitude values in `", y_col, "` must be in [-90, 90].")

  coords <- as.matrix(df[, c(x_col, y_col), drop = FALSE])
  dmat_m <- geosphere::distm(coords, fun = distance_fun) # meters
  dmat   <- if (units == "km") dmat_m / 1000 else dmat_m

  idx <- expand.grid(
    i = seq_len(nrow(df)),
    j = seq_len(nrow(df))
  )
  idx$value <- dmat[cbind(idx$i, idx$j)]
  idx$site_from <- df[[id_col]][idx$i]
  idx$site_to   <- df[[id_col]][idx$j]

  out <- tibble::as_tibble(idx[, c("site_from", "site_to", "value")])

  if (drop_self) out <- dplyr::filter(out, site_from != site_to)

  if (triangle == "upper") {
    out <- dplyr::filter(out, match(site_from, df[[id_col]]) < match(site_to, df[[id_col]]))
  } else if (triangle == "lower") {
    out <- dplyr::filter(out, match(site_from, df[[id_col]]) > match(site_to, df[[id_col]]))
  }

  out
}

# ------------------------------------------------------------------------------
# SPECIES RICHNESS
# ------------------------------------------------------------------------------

#' Calculate species richness
#'
#' Counts the number of non-zero species in a site vector. If `vec_to` is provided,
#' returns the absolute difference in richness between the two vectors.
#'
#' @param vec_from Numeric vector of counts (one site).
#' @param vec_to Optional numeric vector of counts (another site).
#'
#' @return Numeric scalar.
#' @examples
#' calc_richness(c(3, 0, 1, 2, 0))
#' calc_richness(c(3, 0, 1, 2, 0), c(0, 4, 1, 0, 5))
#' @export
#' @keywords internal
calc_richness <- function(vec_from, vec_to = NULL) {
  rf <- sum(vec_from != 0, na.rm = TRUE)
  if (is.null(vec_to)) return(rf)

  rt <- sum(vec_to != 0, na.rm = TRUE)
  abs(rf - rt)
}

# ------------------------------------------------------------------------------
# SPECIES TURNOVER (BETA DIVERSITY)
# ------------------------------------------------------------------------------

#' Calculate species turnover / beta diversity
#'
#' Computes turnover as the proportion of unshared species between two sites
#' (presence/absence implied by counts > 0).
#'
#' @param vec_from Numeric vector of counts (site A).
#' @param vec_to Numeric vector of counts (site B). If `NULL`, returns `NA_real_`.
#'
#' @return Numeric scalar in the range 0 to 1, or `NA_real_` for order = 1.
#' @examples
#' calc_turnover(c(3, 0, 1, 2, 0), c(0, 4, 1, 0, 5))
#' calc_turnover(c(1, 1, 0), NULL)
#' @export
#' @keywords internal
calc_turnover <- function(vec_from, vec_to = NULL) {
  if (is.null(vec_to)) return(NA_real_)

  a <- vec_from != 0
  b <- vec_to   != 0

  total_species  <- sum(a | b, na.rm = TRUE)
  shared_species <- sum(a & b, na.rm = TRUE)

  if (is.na(total_species) || total_species == 0) return(NA_real_)
  (total_species - shared_species) / total_species
}

# ------------------------------------------------------------------------------
# SPECIES ABUNDANCE
# ------------------------------------------------------------------------------

#' Calculate species abundance
#'
#' If `vec_to` is `NULL`, returns total abundance at a site. Otherwise returns the
#' absolute difference in total abundance between two vectors.
#'
#' @param vec_from Numeric vector of counts (site A).
#' @param vec_to Optional numeric vector of counts (site B).
#'
#' @return Numeric scalar.
#' @examples
#' calc_abund(c(3, 0, 1, 2, 0))
#' calc_abund(c(3, 0, 1, 2, 0), c(0, 4, 1, 0, 5))
#' @export
#' @keywords internal
calc_abund <- function(vec_from, vec_to = NULL) {
  af <- sum(vec_from, na.rm = TRUE)
  if (is.null(vec_to)) return(af)

  at <- sum(vec_to, na.rm = TRUE)
  abs(af - at)
}

# ------------------------------------------------------------------------------
# PHI COEFFICIENT (PRESENCE-ABSENCE)
# ------------------------------------------------------------------------------

#' Calculate phi coefficient (presence/absence association)
#'
#' Computes the phi coefficient between two presence/absence vectors derived from
#' counts (>0).
#'
#' @param vec_from Numeric vector of counts (site A).
#' @param vec_to Numeric vector of counts (site B). If `NULL`, returns `NA_real_`.
#'
#' @return Numeric scalar in the range -1 to 1, or `NA_real_` if undefined.
#' @examples
#' calc_phi_coef(c(1, 0, 1, 1, 0), c(1, 1, 0, 1, 0))
#' calc_phi_coef(c(1, 0, 1), NULL)
#' @export
#' @keywords internal
calc_phi_coef <- function(vec_from, vec_to = NULL) {
  if (is.null(vec_to)) return(NA_real_)

  data_i <- as.integer(vec_from > 0)
  data_j <- as.integer(vec_to   > 0)

  A <- sum(data_i == 1 & data_j == 1, na.rm = TRUE)
  B <- sum(data_i == 1 & data_j == 0, na.rm = TRUE)
  C <- sum(data_i == 0 & data_j == 1, na.rm = TRUE)
  D <- sum(data_i == 0 & data_j == 0, na.rm = TRUE)

  denom <- sqrt((A + B) * (A + C) * (B + D) * (C + D))
  if (is.na(denom) || denom == 0) return(NA_real_)

  (A * D - B * C) / denom
}

# ------------------------------------------------------------------------------
# CORRELATIONS (ABUNDANCES)
# ------------------------------------------------------------------------------

#' Calculate Spearman correlation (abundance association)
#'
#' @param vec_from Numeric vector (site A).
#' @param vec_to Numeric vector (site B). If `NULL`, returns `NA_real_`.
#'
#' @return Numeric scalar correlation, or `NA_real_`.
#' @examples
#' calc_cor_spear(c(1, 3, 5, 7, 9), c(2, 4, 6, 8, 10))
#' calc_cor_spear(c(1, 3, 5), NULL)
#' @export
#' @keywords internal
calc_cor_spear <- function(vec_from, vec_to = NULL) {
  if (is.null(vec_to)) return(NA_real_)
  if (length(vec_from) <= 1 || length(vec_to) <= 1) return(NA_real_)

  stats::cor(vec_from, vec_to, method = "spearman", use = "pairwise.complete.obs")
}

#' Calculate Pearson correlation (abundance association)
#'
#' @param vec_from Numeric vector (site A).
#' @param vec_to Numeric vector (site B). If `NULL`, returns `NA_real_`.
#'
#' @return Numeric scalar correlation, or `NA_real_`.
#' @examples
#' calc_cor_pears(c(1, 3, 5, 7, 9), c(2, 4, 6, 8, 10))
#' calc_cor_pears(c(1, 3, 5), NULL)
#' @export
#' @keywords internal
calc_cor_pears <- function(vec_from, vec_to = NULL) {
  if (is.null(vec_to)) return(NA_real_)
  if (length(vec_from) <= 1 || length(vec_to) <= 1) return(NA_real_)

  stats::cor(vec_from, vec_to, method = "pearson", use = "pairwise.complete.obs")
}

# ------------------------------------------------------------------------------
# DISSIMILARITIES
# ------------------------------------------------------------------------------

#' Calculate Bray-Curtis dissimilarity (abundance)
#'
#' Uses `vegan::vegdist()` on a 2-row matrix.
#'
#' @param vec_from Numeric vector (site A).
#' @param vec_to Numeric vector (site B). If `NULL`, returns `NA_real_`.
#'
#' @return Numeric scalar in the range 0 to 1 or `NA_real_`.
#' @examples
#' \dontrun{
#' calc_diss_bcurt(c(3, 0, 1, 2), c(0, 4, 1, 5))
#' }
#' @export
#' @keywords internal
calc_diss_bcurt <- function(vec_from, vec_to = NULL) {
  if (is.null(vec_to)) return(NA_real_)
  if (length(vec_from) <= 1 || length(vec_to) <= 1) return(NA_real_)

  if (!requireNamespace("vegan", quietly = TRUE)) {
    stop("Package 'vegan' is required for Bray-Curtis. Please install it.")
  }

  as.numeric(vegan::vegdist(rbind(vec_from, vec_to), method = "bray")[1])
}

#' Calculate Gower dissimilarity (two vectors)
#'
#' Uses `cluster::daisy()` with metric = "gower".
#'
#' @param vec_from Numeric vector (site A).
#' @param vec_to Numeric vector (site B). If `NULL`, returns `NA_real_`.
#'
#' @return Numeric scalar in the range 0 to 1 or `NA_real_`.
#' @examples
#' calc_gower(c(3, 0, 1, 2), c(0, 4, 1, 5))
#' calc_gower(c(1, 2, 3), NULL)
#' @export
#' @keywords internal
calc_gower <- function(vec_from, vec_to = NULL) {
  if (is.null(vec_to)) return(NA_real_)
  if (length(vec_from) <= 1 || length(vec_to) <= 1) return(NA_real_)

  M <- rbind(vec_from, vec_to)
  diss <- cluster::daisy(M, metric = "gower", stand = FALSE)
  as.numeric(diss)
}

#' Calculate Gower dissimilarity (orderwise alias)
#'
#' Kept for backward compatibility; same behaviour as `calc_gower()`.
#'
#' @param vec_from Numeric vector (site A).
#' @param vec_to Optional numeric vector (site B).
#'
#' @return Numeric scalar in the range 0 to 1 or `NA_real_`.
#' @examples
#' calc_orderwise_gower(c(3, 0, 1, 2), c(0, 4, 1, 5))
#' calc_orderwise_gower(c(1, 2, 3), NULL)
#' @export
#' @keywords internal
calc_orderwise_gower <- function(vec_from, vec_to = NULL) {
  calc_gower(vec_from, vec_to)
}

#' Pairwise Gower dissimilarity matrix (long format)
#'
#' Computes pairwise Gower dissimilarities between rows of `df` using columns in
#' `sp_cols`. Returns long format with site IDs.
#'
#' @param df Data frame containing a site identifier and species/trait columns.
#' @param sp_cols Character vector of numeric (or mixed) columns to use in Gower.
#' @param id_col Site ID column name (default "grid_id").
#' @param triangle Which pairs to return: "all" (default), "upper", or "lower".
#' @param drop_self Drop self-pairs (default TRUE).
#'
#' @return A tibble with columns site_from, site_to, value.
#' @export
#' @keywords internal
calculate_pairwise_gower_dist_matrix <- function(
    df,
    sp_cols,
    id_col   = "grid_id",
    triangle = c("all", "upper", "lower"),
    drop_self = TRUE
) {
  triangle <- match.arg(triangle)

  if (!all(c(id_col, sp_cols) %in% names(df))) {
    stop("`df` must contain columns: ", paste(c(id_col, sp_cols), collapse = ", "))
  }

  X <- df[, sp_cols, drop = FALSE]
  if (nrow(X) < 2) stop("Need at least 2 rows to compute pairwise Gower distances.")

  diss <- cluster::daisy(X, metric = "gower", stand = FALSE)
  dmat <- as.matrix(diss)

  idx <- expand.grid(i = seq_len(nrow(df)), j = seq_len(nrow(df)))
  idx$value <- dmat[cbind(idx$i, idx$j)]
  idx$site_from <- df[[id_col]][idx$i]
  idx$site_to   <- df[[id_col]][idx$j]

  out <- tibble::as_tibble(idx[, c("site_from", "site_to", "value")])

  if (drop_self) out <- dplyr::filter(out, site_from != site_to)

  if (triangle == "upper") {
    out <- dplyr::filter(out, match(site_from, df[[id_col]]) < match(site_to, df[[id_col]]))
  } else if (triangle == "lower") {
    out <- dplyr::filter(out, match(site_from, df[[id_col]]) > match(site_to, df[[id_col]]))
  }

  out
}

# ------------------------------------------------------------------------------
# MUTUAL INFORMATION
# ------------------------------------------------------------------------------

#' Calculate mutual information (plugin estimator)
#'
#' Computes mutual information between two vectors using `entropy::mi.plugin()` on
#' the joint frequency table. For continuous variables, consider binning first.
#'
#' @param vec_from Vector (numeric, integer, factor, character).
#' @param vec_to Vector (numeric, integer, factor, character). If `NULL`, returns `NA_real_`.
#'
#' @return Non-negative numeric scalar, or `NA_real_`.
#' @examples
#' \dontrun{
#' calc_mutual_info(c(1, 2, 1, 2, 1), c(1, 1, 2, 2, 1))
#' }
#' @export
#' @keywords internal
calc_mutual_info <- function(vec_from, vec_to = NULL) {
  if (is.null(vec_to)) return(NA_real_)
  if (length(vec_from) <= 1 || length(vec_to) <= 1) return(NA_real_)

  if (!requireNamespace("entropy", quietly = TRUE)) {
    stop("Package 'entropy' is required for mutual information. Please install it.")
  }

  ok <- stats::complete.cases(vec_from, vec_to)
  if (!any(ok)) return(NA_real_)

  joint_dist <- table(vec_from[ok], vec_to[ok])
  as.numeric(entropy::mi.plugin(joint_dist))
}
