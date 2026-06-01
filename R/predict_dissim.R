#' Predict Pairwise Compositional Turnover (zeta-dissimilarity) with Richness
#'
#' @description
#' Takes raw species and environmental data, fits a multi-site GDM model output,
#' computes predicted pairwise turnover (zeta2) across the landscape, and returns a
#' data frame with site-level richness, environmental covariates, distance, and
#' predicted turnover; optionally plots a heatmap of zeta2 predictions.
#'
#' @param grid_spp     Data frame containing site IDs, coordinates, and species
#'                     presence-absence/abundance columns.
#' @param species_cols Integer or character vector giving the columns of
#'                     \code{grid_spp} that hold species data.
#' @param env_vars     Data frame of raw environmental predictors (unscaled;
#'                     rows must align with \code{grid_spp}).
#' @param zeta_model   Fitted object from \code{\link[zetadiv]{Zeta.msgdm}}
#'                     (order = 2, reg.type = "ispline").
#' @param grid_xy      Data frame of site coordinates, same row-order as
#'                     \code{grid_spp}, with columns \code{x_col}, \code{y_col}.
#' @param bndy_fc      Optional \code{sf} or \code{SpatVector} polygon to overlay.
#' @param x_col        Name of the x (longitude) column in \code{grid_spp}/\code{grid_xy}.
#' @param y_col        Name of the y (latitude) column.
#' @param show_plot    Logical; if TRUE (default), attach a turnover heatmap as
#'   the `"plot"` attribute of the returned data frame. Access via
#'   `attr(result, "plot")`.
#' @param skip_scale   Logical; if TRUE, skip centering and scaling of
#'   environmental variables (default FALSE).
#'
#' @return
#' A data frame (returned invisibly) with one row per site, containing:
#' \describe{
#'   \item{richness}{Species richness (sum across \code{species_cols}).}
#'   \item{distance}{Mean great-circle distance (km) from each site to all others.}
#'   \item{<env_vars>}{All scaled environmental predictors.}
#'   \item{pred_zeta}{Linear predictor (logit scale) from \code{Predict.msgdm()}.}
#'   \item{pred_zetaExp}{Predicted turnover (0-1 scale).}
#'   \item{log_pred_zetaExp}{Natural log of \code{pred_zetaExp}.}
#'   \item{x_col, y_col}{Site coordinates (from \code{grid_xy}).}
#' }
#' When `show_plot = TRUE`, the ggplot object is attached as `attr(result, "plot")`.
#'
#' @examples
#' \dontrun{
#' result <- predict_dissim(
#'   grid_spp     = bird.spec.fine,
#'   species_cols = 3:102,
#'   env_vars     = bird.env.fine[,3:9],
#'   zeta_model   = z_mod,
#'   grid_xy      = bird.spec.fine[,1:2],
#'   bndy_fc      = rsa,
#'   x_col        = "x",
#'   y_col        = "y",
#'   show_plot    = FALSE
#' )
#' }
#' @export
predict_dissim <- function(
    grid_spp,
    species_cols,
    env_vars,
    zeta_model,
    grid_xy,
    bndy_fc   = NULL,
    x_col     = "x",
    y_col     = "y",
    show_plot = TRUE,
    skip_scale = FALSE
) {

  # 1) sanity
  req_meta <- c(x_col, y_col)
  if (!all(req_meta %in% names(grid_xy))) {
    stop("`grid_xy` must contain: ", paste(req_meta, collapse = ", "))
  }
  if (!all(c(x_col, y_col) %in% names(grid_spp))) {
    stop("`grid_spp` must contain: ", x_col, ", ", y_col)
  }

  # 2) richness
  spp_mat  <- as.matrix(grid_spp[, species_cols])
  richness <- rowSums(spp_mat, na.rm = TRUE)

  # 3) scale environmental data
  if (!skip_scale) {
    env_scaled <- as.data.frame(scale(env_vars))
  } else {
    env_scaled <- env_vars  # assume already scaled externally
  }

  # 4) distances
  dist_mat <- calculate_pairwise_distances_matrix(
    data  = grid_xy, x_col = x_col, y_col = y_col
  )
  mean_dist <- dist_mat %>%
    dplyr::group_by(site_from) %>%
    dplyr::summarise(distance = mean(value, na.rm = TRUE), .groups = "drop")
  coords <- grid_xy[match(mean_dist$site_from, rownames(grid_xy)), ]
  mean_dist[[x_col]] <- coords[[x_col]]
  mean_dist[[y_col]] <- coords[[y_col]]

  # 5) table
  predictors_df <- env_scaled %>% dplyr::mutate(distance = mean_dist$distance)

  # 6) ispline + predict
  splines <- zetadiv::Ispline(predictors_df, order.ispline = 2)
  preds   <- zetadiv::Predict.msgdm(
    zeta_model$model, splines$splines,
    reg.type = "ispline", type = "response"
  )

  # 7) assemble
  results_df <- predictors_df %>%
    dplyr::mutate(
      richness         = richness,
      pred_zeta        = preds,
      pred_zetaExp     = exp(preds)/(1+exp(preds)),
      log_pred_zetaExp = log(pred_zetaExp),
      !!x_col          := grid_xy[[x_col]],
      !!y_col          := grid_xy[[y_col]]
    )

  # 8) plot if requested
  if (show_plot) {
    pal <- colorRampPalette(c("blue","green","yellow","orange","red"))(10)
    p <- ggplot2::ggplot(results_df,
                ggplot2::aes(x = .data[[x_col]], y = .data[[y_col]], fill = .data[["pred_zetaExp"]])) +
      ggplot2::geom_tile() +
      ggplot2::scale_fill_gradientn(colors = pal) +
      ggplot2::theme_minimal() +
      ggplot2::labs(x = x_col, y = y_col, fill = "Predicted\nTurnover") +
      ggplot2::theme(panel.grid = ggplot2::element_blank())
    if (!is.null(bndy_fc)) {
      p <- p + ggplot2::geom_sf(data = bndy_fc, inherit.aes = FALSE,
                       fill = NA, color = "black")
    }
    attr(results_df, "plot") <- p
  }

  invisible(results_df)
}
