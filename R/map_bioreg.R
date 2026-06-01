#' Raster-based Clustering and Interpolation of Bioregional Data
#'
#' `map_bioreg` performs clustering (k-means, PAM, hierarchical, GMM) on spatial point data,
#' computes modal or user-specified interpolation (none, nearest-neighbour, TPS), aligns
#' cluster labels by overlap, and returns both data tables and raster stacks.
#'
#' @param data A single data.frame of point observations or a named list of such data.frames (e.g. different scenarios).
#'   Each data.frame must contain coordinate columns and variables to scale.
#' @param scale_cols Character vector of column names in `data` to standardize before clustering.
#' @param method Character vector of clustering methods to apply; choices of "kmeans", "pam", "hclust", "gmm", or "all".
#' @param k_override Integer. If provided, fixes the number of clusters rather than computing via silhouette.
#' @param x_col,y_col Strings giving the names of the longitude (x) and latitude (y) columns for spatial mapping.
#' @param interpolate One of "none", "nn", "tps", or "all"; selects which interpolation(s) to compute.
#' @param res Numeric resolution of output rasters (in the same units as coordinates).
#' @param crs Coordinate reference system string for raster outputs (e.g. "EPSG:4326").
#' @param plot Logical; if TRUE, displays spatial tile plots of clusters/modes.
#' @param bndy_fc      Optional \code{sf} or \code{SpatVector} polygon to overlay.
#'
#' @return A named list with elements:
#'   \describe{
#'     \item{none, nn, tps}{Named lists of Terra SpatRaster stacks for each scenario, each layer labelled "<method>_algn_<scenario>".}
#'     \item{table}{A data.frame: original points, cluster columns, modal label, aligned labels.}
#'     \item{plots}{List of individual ggplot objects when `plot = TRUE`.}
#'     \item{combined_plot}{A single combined patchwork plot when `plot = TRUE`, `NULL` otherwise. Call `print()` on this object to display it.}
#'     \item{methods}{Character vector of methods actually computed.}
#'   }
#'
#' @details
#' Internally, the function standardizes `scale_cols`, runs requested clustering(s),
#' computes a modal consensus label, and then aligns each algorithm's cluster numbers
#' to the k-means reference by maximal cell overlap. Three interpolation functions
#' (`fill_none_full`, `fill_nn_full`, `fill_tps_full`) generate rasters of raw and aligned
#' labels. Progress bars display per scenario.
#'
#' @examples
#' if (requireNamespace("terra", quietly = TRUE)) {
#'   # simulate a single data.frame
#'   set.seed(42)
#'   df <- data.frame(
#'     centroid_lon = runif(100, 16, 33),
#'     centroid_lat = runif(100, -35, -22),
#'     pred_zetaExp = rnorm(100)
#'   )
#'
#'   # single scenario clustering (use a method that does NOT require optional packages)
#'   out1 <- map_bioreg(
#'     data       = df,
#'     scale_cols  = c("pred_zetaExp", "centroid_lon", "centroid_lat"),
#'     method      = "kmeans",
#'     k_override  = 4,
#'     x_col       = "centroid_lon",
#'     y_col       = "centroid_lat",
#'     interpolate = "none",
#'     plot        = FALSE
#'   )
#'   out1$methods
#'
#'   # simulate multiple scenarios
#'   df2 <- df
#'   df2$centroid_lon <- df2$centroid_lon + 5
#'   scen_list <- list(current = df, future = df2)
#'
#'   out2 <- map_bioreg(
#'     data       = scen_list,
#'     scale_cols  = c("pred_zetaExp", "centroid_lon", "centroid_lat"),
#'     method      = "kmeans",
#'     k_override  = 3,
#'     x_col       = "centroid_lon",
#'     y_col       = "centroid_lat",
#'     interpolate = "none",
#'     plot        = FALSE
#'   )
#'   out2$methods
#' }
#'
#' # Optional GMM clustering requires the 'mclust' package:
#' # if (requireNamespace("mclust", quietly = TRUE) && requireNamespace("terra", quietly = TRUE)) {
#' #   out_gmm <- map_bioreg(df, c("pred_zetaExp", "centroid_lon", "centroid_lat"), method = "gmm",
#' #                         k_override = 4, x_col = "centroid_lon", y_col = "centroid_lat",
#' #                         interpolate = "none", plot = FALSE)
#' # }
#' @importFrom terra rast ext vect crds rasterize setValues levels
#' @importFrom fields Tps
#' @importFrom sf st_as_sf
#' @importFrom NbClust NbClust
#' @importFrom cluster pam
#' @importFrom factoextra hcut
#' @importFrom pbapply pblapply
#' @importFrom dplyr bind_rows group_split
#' @importFrom tidyr pivot_longer
#' @importFrom rlang .data
#' @importFrom ggplot2 ggplot geom_tile aes scale_fill_manual labs theme_minimal facet_wrap geom_sf
#' @importFrom patchwork wrap_plots
#' @export
map_bioreg = function(data,
                      scale_cols,
                      method      = c("kmeans","pam","hclust","gmm","all"),
                      k_override  = NULL,
                      x_col       = "x",
                      y_col       = "y",
                      interpolate = c("none","nn","tps","all"),
                      res         = 0.5,
                      crs         = "EPSG:4326",
                      plot        = TRUE,
                      bndy_fc     = NULL) {
  #-- helper: no-interpolation (modal majority per cell)
  fill_none_full = function(df, x_col, y_col, cls_col, res, crs) {
    xy  = as.matrix(df[, c(x_col, y_col)])
    ids = as.integer(df[[cls_col]])
    r   = terra::rast(terra::ext(range(xy[,1]), range(xy[,2])), resolution=res, crs=crs)
    pts = terra::vect(data.frame(x=xy[,1], y=xy[,2], cls=ids), geom=c("x","y"), crs=crs)
    majority = function(x, ...) { if(all(is.na(x))) NA_integer_ else {ux=unique(x); ux[which.max(tabulate(match(x,ux)))] }}
    rcls = terra::rasterize(pts, r, field="cls", fun=majority, background=NA_integer_)
    levels(rcls) = data.frame(value=sort(unique(ids)), lbl=as.character(sort(unique(ids))))
    names(rcls) = cls_col
    rcls
  }

  #-- helper: nearest-neighbour fill
  fill_nn_full = function(df, x_col, y_col, cls_col, res, crs) {
    xy  = as.matrix(df[, c(x_col, y_col)])
    ids = as.integer(df[[cls_col]])
    r   = terra::rast(terra::ext(range(xy[,1]), range(xy[,2])), resolution=res, crs=crs)
    idx = apply(terra::crds(r), 1, function(pt) which.min(colSums((t(xy)-pt)^2)))
    r   = terra::setValues(r, ids[idx])
    levels(r) = data.frame(value=sort(unique(ids)), lbl=as.character(sort(unique(ids))))
    names(r) = cls_col
    r
  }

  #-- helper: thin-plate spline fill
  fill_tps_full = function(df, x_col, y_col, cls_col, res, crs) {
    r = terra::rast(terra::ext(range(df[[x_col]]), range(df[[y_col]])), resolution=res, crs=crs)
    fit = fields::Tps(as.matrix(df[, c(x_col, y_col)]), as.numeric(df[[cls_col]]))
    rnum = terra::interpolate(r, fit)
    rcls = terra::setValues(r, as.integer(terra::values(round(rnum))))
    levels(rcls) = data.frame(value=sort(unique(as.integer(df[[cls_col]]))),
                              lbl=as.character(sort(unique(as.integer(df[[cls_col]])))))
    names(rcls) = cls_col
    rcls
  }

  #-- 0. unpack and name scenarios
  if (inherits(data, "data.frame")) {
    df_list = list(current = data)
  } else if (is.list(data) && all(vapply(data, is.data.frame, logical(1)))) {
    df_list = data
    if (is.null(names(df_list))) names(df_list) = paste0("set", seq_along(df_list))
  } else stop("`data` must be a data.frame or list of data.frames")

  #-- 1. argument processing
  method      = match.arg(method, several.ok=TRUE)
  if ("all" %in% method) method = c("kmeans","pam","hclust","gmm")
  interpolate = match.arg(interpolate)
  dat         = dplyr::bind_rows(df_list, .id="scenario")
  zmat        = scale(dat[, scale_cols])
  if (!all(c(x_col, y_col) %in% names(dat))) stop("x_col/y_col not found in data.")

  #-- 2. choose number of clusters
  k = if(!is.null(k_override)) k_override else
    NbClust::NbClust(zmat, "euclidean", 2, 10, "kmeans", "silhouette")$Best.nc[1]

  #-- 3. run clustering methods
  if ("kmeans" %in% method) dat$kmeans = stats::kmeans(zmat, k, nstart=10)$cluster
  if ("pam"    %in% method) dat$pam    = cluster::pam(zmat, k)$clustering
  if ("hclust" %in% method) dat$hclust = factoextra::hcut(zmat, k)$cluster
  if ("gmm"    %in% method) {
    if (!requireNamespace("mclust", quietly = TRUE)) {
      stop("Package 'mclust' is required for method = 'gmm'. Please install it or choose a different method.")
    }
    # Some mclust versions rely on mclustBIC internally; check availability for clearer errors
    if (!exists("mclustBIC", envir = asNamespace("mclust"), inherits = FALSE)) {
      stop("Your installed 'mclust' does not provide 'mclustBIC' in its namespace. Please update the mclust package.")
    }
    dat$gmm <- mclust::Mclust(zmat, G=k)$classification
  }
  algo_cols = intersect(c("kmeans","pam","hclust","gmm"), names(dat))

  #-- 4. modal consensus label
  mode_row = function(r) { r = na.omit(r); r[which.max(tabulate(match(r,r)))] }
  dat$cluster_mode = factor(apply(dat[algo_cols],1,mode_row), levels=1:k)

  #-- 5. align by overlap (_algn suffix)
  align_by_overlap = function(ref, clust) {
    tab = table(ref, clust)
    map = apply(tab,2, function(col) as.integer(names(which.max(col))))
    unname(map[as.character(clust)])
  }
  aligned_cols = paste0(algo_cols, "_algn")
  for (i in seq_along(algo_cols)) {
    dat[[aligned_cols[i]]] = align_by_overlap(dat$kmeans, dat[[algo_cols[i]]])
  }
  cluster_cols = c(algo_cols, aligned_cols)

  #-- 6. plotting
  plots = NULL
  combined_plot = NULL
  if (plot) {
    # prepare palette
    pal = if (k <= 12) RColorBrewer::brewer.pal(k, "Set3") else
      colorRampPalette(RColorBrewer::brewer.pal(12, "Set3"))(k)

    # if boundary provided, convert to sf
    if (!is.null(bndy_fc)) {
      if (inherits(bndy_fc, "SpatVector")) {
        bndy_sf = sf::st_as_sf(bndy_fc)
      } else if (inherits(bndy_fc, "sf")) {
        bndy_sf = bndy_fc
      } else {
        stop("`bndy_fc` must be an sf or SpatVector object.")
      }
    }

    n_scn = length(unique(dat$scenario))
    n_alg = length(algo_cols)

    if (n_scn == 1 && n_alg > 1) {
      # single scenario: plot aligned clusters
      dat_long = tidyr::pivot_longer(dat, cols = dplyr::all_of(aligned_cols),
                                     names_to = "algorithm", values_to = "cluster")
      p = ggplot2::ggplot(dat_long) +
        ggplot2::geom_tile(ggplot2::aes(x = .data[[x_col]], y = .data[[y_col]], fill = factor(.data[["cluster"]]))) +
        ggplot2::scale_fill_manual(values = pal, drop = FALSE) +
        ggplot2::facet_wrap(~algorithm) +
        ggplot2::labs(title = unique(dat_long$scenario), fill = "Cluster") +
        ggplot2::theme_minimal()
      # overlay boundary if present
      if (!is.null(bndy_fc)) p = p + ggplot2::geom_sf(data = bndy_sf, fill = NA, color = "black", inherit.aes = FALSE)
      plots = list(p)
    } else {
      # multiple scenarios or single algorithm
      plots = dat |> dplyr::group_split(.data[["scenario"]]) |> lapply(function(dd) {
        sc = unique(dd$scenario)
        if (length(algo_cols) > 1) {
          mapping = ggplot2::aes(x = .data[[x_col]], y = .data[[y_col]], fill = .data[["cluster_mode"]])
          fill_lab = "Mode"
        } else {
          mapping = ggplot2::aes(x = .data[[x_col]], y = .data[[y_col]],
                                 fill = factor(.data[[algo_cols[1]]]))
          fill_lab = algo_cols[1]
        }
        p = ggplot2::ggplot(dd) +
          ggplot2::geom_tile(mapping) +
          ggplot2::scale_fill_manual(values = pal, drop = FALSE) +
          ggplot2::labs(title = sc, fill = fill_lab) +
          ggplot2::theme_minimal()
        # overlay boundary if present
        if (!is.null(bndy_fc)) p = p + ggplot2::geom_sf(data = bndy_sf, fill = NA, color = "black", inherit.aes = FALSE)
        p
      })
    }
    combined_plot = patchwork::wrap_plots(plots)
  }

  #-- 7. build raster stacks
  make_stack = function(fun) {
    scen_list = split(dat,dat$scenario)
    pbapply::pblapply(scen_list, function(dd){
      sc = unique(dd$scenario)
      lays = lapply(cluster_cols, function(col){
        r = fun(dd, x_col, y_col, col, res, crs)
        names(r) = col; r
      })
      stk = do.call(c,lays)
      names(stk) = paste0(cluster_cols,"_",sc)
      stk
    })
  }

  #-- 8. return list
  list(
    none    = make_stack(fill_none_full),
    nn      = if(interpolate %in% c("nn","all")) make_stack(fill_nn_full) else NULL,
    tps     = if(interpolate %in% c("tps","all")) make_stack(fill_tps_full) else NULL,
    table   = dat,
    plots   = plots,
    combined_plot = combined_plot,
    methods = algo_cols
  )
}
