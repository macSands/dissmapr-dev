# dissmapr 0.1.0

* Initial release of the dissmapr package.
* Added `get_occurrence_data()` to import and harmonise biodiversity occurrence records.
* Added `format_df()` to convert between long and wide biodiversity data layouts.
* Added `generate_grid()` to build spatial grids and compute gridded species summaries.
* Added `assign_mapsheet()` to assign mapsheet codes to spatial points.
* Added `get_enviro_data()` to retrieve, crop, and extract environmental rasters.
* Added `rm_correlated()` to remove highly correlated predictors.
* Added `compute_orderwise()` for multi-order ecological metric computation.
* Added `run_ispline_models()` to fit Zeta.msgdm ispline models across zeta orders.
* Added `predict_dissim()` to predict pairwise compositional turnover.
* Added `plot_ispline_lines()` and `plot_ispline_boxplots()` for ispline visualisation.
* Added `map_bioreg()` for clustering and interpolation of bioregional data.
* Added `map_bioreg_diff()` to map bioregional change metrics.
* Added helper index functions: `calc_richness()`, `calc_turnover()`, `calc_abund()`, `calc_phi_coef()`, `calc_cor_spear()`, `calc_cor_pears()`, `calc_diss_bcurt()`, `calc_orderwise_gower()`, `calc_mutual_info()`, `calc_geodist()`.
