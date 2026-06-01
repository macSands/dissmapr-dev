# Package index

## Data Import and Preparation

- [`get_occurrence_data()`](https://b-cubed-eu.github.io/dissmapr/reference/get_occurrence_data.md)
  : Import and harmonise biodiversity-occurrence data
- [`format_df()`](https://b-cubed-eu.github.io/dissmapr/reference/format_df.md)
  : Format Biodiversity Records to Long / Wide
- [`generate_grid()`](https://b-cubed-eu.github.io/dissmapr/reference/generate_grid.md)
  : Generate Spatial Grid and Gridded Summaries
- [`assign_mapsheet()`](https://b-cubed-eu.github.io/dissmapr/reference/assign_mapsheet.md)
  : Add Nearest Mapsheet Code and Center Coordinates
- [`get_enviro_data()`](https://b-cubed-eu.github.io/dissmapr/reference/get_enviro_data.md)
  : Retrieve, crop, resample, and link environmental rasters to sampling
  sites
- [`rm_correlated()`](https://b-cubed-eu.github.io/dissmapr/reference/rm_correlated.md)
  : Remove Highly Correlated Predictors

## Metric Computation

- [`compute_orderwise()`](https://b-cubed-eu.github.io/dissmapr/reference/compute_orderwise.md)
  : Compute Order-wise Metrics
- [`calc_richness()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_richness.md)
  : Calculate species richness
- [`calc_turnover()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_turnover.md)
  : Calculate species turnover / beta diversity
- [`calc_abund()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_abund.md)
  : Calculate species abundance
- [`calc_phi_coef()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_phi_coef.md)
  : Calculate phi coefficient (presence/absence association)
- [`calc_cor_spear()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_cor_spear.md)
  : Calculate Spearman correlation (abundance association)
- [`calc_cor_pears()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_cor_pears.md)
  : Calculate Pearson correlation (abundance association)
- [`calc_diss_bcurt()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_diss_bcurt.md)
  : Calculate Bray-Curtis dissimilarity (abundance)
- [`calc_orderwise_gower()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_orderwise_gower.md)
  : Calculate Gower dissimilarity (orderwise alias)
- [`calc_mutual_info()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_mutual_info.md)
  : Calculate mutual information (plugin estimator)
- [`calc_geodist()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_geodist.md)
  : Calculate geographic distance via Haversine formula
- [`calc_distance()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_distance.md)
  : Calculate distance between sites in a coordinate table
- [`calc_gower()`](https://b-cubed-eu.github.io/dissmapr/reference/calc_gower.md)
  : Calculate Gower dissimilarity (two vectors)
- [`calculate_pairwise_distances_matrix()`](https://b-cubed-eu.github.io/dissmapr/reference/calculate_pairwise_distances_matrix.md)
  : Pairwise distance matrix (long format)
- [`calculate_pairwise_gower_dist_matrix()`](https://b-cubed-eu.github.io/dissmapr/reference/calculate_pairwise_gower_dist_matrix.md)
  : Pairwise Gower dissimilarity matrix (long format)

## Zeta Diversity Modelling

- [`run_ispline_models()`](https://b-cubed-eu.github.io/dissmapr/reference/run_ispline_models.md)
  : Run multiple Zeta.msgdm ispline models and return both models and
  combined ispline table
- [`predict_dissim()`](https://b-cubed-eu.github.io/dissmapr/reference/predict_dissim.md)
  : Predict Pairwise Compositional Turnover (zeta-dissimilarity) with
  Richness

## Visualisation

- [`plot_ispline_lines()`](https://b-cubed-eu.github.io/dissmapr/reference/plot_ispline_lines.md)
  : Plot ispline partial effects with quantile and start-point markers
- [`plot_ispline_boxplots()`](https://b-cubed-eu.github.io/dissmapr/reference/plot_ispline_boxplots.md)
  : Plot facetted boxplots for all ispline basis columns
- [`map_bioreg()`](https://b-cubed-eu.github.io/dissmapr/reference/map_bioreg.md)
  : Raster-based Clustering and Interpolation of Bioregional Data
- [`map_bioreg_diff()`](https://b-cubed-eu.github.io/dissmapr/reference/map_bioreg_diff.md)
  : Map Bioregional Change Metrics Between Categorical Raster Layers
