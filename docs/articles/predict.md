# Predict community turnover

------------------------------------------------------------------------

## `dissmapr`

### A Novel Framework for Automated Compositional Dissimilarity and Biodiversity Turnover Analysis

------------------------------------------------------------------------

#### 1. Predict current Zeta Diversity (zeta2) using `predict_dissim()`

In this step we use our fitted order-2 GDM (`zeta2`) to generate a
spatial map of pairwise compositional turnover (ζ₂) under current
conditions. By `calling predict_dissim()` we

1.  compute each site’s sampling‐effort‐adjusted species richness and
    mean distance to all other sites;  
2.  apply the same environmental I-spline transformations used in the
    model;  
3.  predict the Jaccard-scaled turnover (ζ₂) on the 0–1 scale;  
4.  optionally plot the resulting heatmap with your study boundary
    overlaid.

We set a random seed for reproducibility (so Monte Carlo sampling inside
[`predict_dissim()`](https://b-cubed-eu.github.io/dissmapr/reference/predict_dissim.md)
yields the same results each time), pull out just the species columns
once, then inspect the returned `predictors_df` to confirm its
dimensions, column names, and a quick peek at the key model outputs.

``` r
# Predict current zeta diversity using `predict_dissim` with sampling effort, geographic distance and environmental variables
# Only non-colinear environmental variables used in `zeta2` model
set.seed(123) # set.seed to generate exactly the same random results i.e. sam=100

# Reproject `rsa` to Albers Equal Area (EPSG 9822)
rsa_aea = sf::st_transform(rsa, 9822)

spp_cols = names(grid_spp_pa[,-(1:7)])
predictors_df   = dissmapr::predict_dissim(
  grid_spp      = grid_spp_pa,
  species_cols  = spp_cols,
  env_vars      = env_vars_reduced,# env_vars_reduced[,-8]
  # zeta_model    = zeta2, # From simple order 2 run above
  zeta_model = ispline_gdm_tab$zeta_gdm_list[[1]], # From list of Zeta.msgdm models
  grid_xy       = grid_env,
  x_col         = "centroid_lon",
  y_col         = "centroid_lat",
  # x_col         = "x_aea",
  # y_col         = "y_aea",
  # bndy_fc       = rsa_aea, # Optional feature collection to plot as boundary
  bndy_fc       = rsa, # Optional feature collection to plot as boundary
  show_plot     = TRUE
)

# Check results
dim(predictors_df)
names(predictors_df)
head(predictors_df[,5:11])
```

------------------------------------------------------------------------

#### 2. Predict future Zeta Diversity using `predict_dissim()`

Below we expand our workflow to forecast how ζ₂ respond to three extreme
climate futures (2030, 2040, 2050) alongside the current scenario.

First, we define and center-scale each future by adding large
temperature increments and rainfall multipliers, then bundle them into a
named list of four environmental data frames:

``` r
# 1. Identify species & env columns
# spp_cols  = names(grid_spp_pa)[-(1:7)]
all_vars  = names(env_vars_reduced)
temp_vars = grep("^temp", all_vars, value = TRUE)
rain_vars = grep("^rain", all_vars, value = TRUE)
iso_vars = grep("^iso", all_vars, value = TRUE)
obs_var = "obs_sum"

# 2. Extreme future shifts
horizons     = c("2030","2040","2050")
mean_delta   = list(
  temp  = c("2030"= +2,  "2040"= +4,  "2050"= +6),
  iso   = c("2030"= +0.5,"2040"= +1.0,"2050"= +1.5),
  rain  = c("2030"= 0.9, "2040"= 0.8, "2050"= 0.7),
  effort= c("2030"= 1.3, "2040"= 1.6, "2050"= 2.0)
)
exagg_factor = c("2030"=1.5, "2040"=2.0, "2050"=2.5)

# 3) helper to amplify deviation from the mean
amplify = function(x, factor) {
  m = mean(x, na.rm=TRUE)
  m + (x - m) * factor
}

# # 4. Save original scaling parameters
# sc_params = scale(env_vars_reduced)
# mu    = attr(sc_params, "scaled:center")
# sigma = attr(sc_params, "scaled:scale")

# 4. Build list of future env tibbles
env_scenarios = append(
  list(current = env_vars_reduced),
  setNames(
    lapply(horizons, function(yr) {
      
      yr_chr = as.character(yr)
      
      d_temp   = mean_delta$temp[[yr_chr]]
      d_iso    = mean_delta$iso[[yr_chr]]
      d_rain   = mean_delta$rain[[yr_chr]]
      d_effort = mean_delta$effort[[yr_chr]]
      exagg    = exagg_factor[[yr_chr]]
      
      df = env_vars_reduced
      
      for (v in temp_vars) df[[v]] = df[[v]] + d_temp
      for (v in iso_vars)  df[[v]] = df[[v]] + d_iso
      for (v in rain_vars) df[[v]] = df[[v]] * d_rain
      df[[obs_var]] = df[[obs_var]] * d_effort
      
      for (v in temp_vars) df[[v]] = amplify(df[[v]], factor = exagg)
      for (v in iso_vars)  df[[v]] = amplify(df[[v]], factor = exagg)
      
      df[[obs_var]] = pmin(pmax(df[[obs_var]], 50), 8000)
      
      df
    }),
    horizons
  )
)
# names(env_scenarios) = names(horizons)

# 5. Prepend current conditions
# env_scenarios = c(list(current = env_vars_reduced), env_futures)
str(env_scenarios, max.level = 1)
```

Next, we loop through each scenario, re-apply the original centering and
scaling, and call our
[`predict_dissim()`](https://b-cubed-eu.github.io/dissmapr/reference/predict_dissim.md)
helper to compute ζ₂. We tag each result with its scenario name and
combine them into one tidy data frame:

``` r
set.seed(123)

scenario_dfs = purrr::imap(env_scenarios, ~ {
  df = dissmapr::predict_dissim(
    grid_spp     = grid_spp,
    species_cols = spp_cols,
    env_vars     = .x,
    # zeta_model   = zeta2,
    zeta_model = ispline_gdm_tab$zeta_gdm_list[[3]], # From list of Zeta.msgdm models
    grid_xy      = grid_env,
    x_col        = "centroid_lon",
    y_col        = "centroid_lat",
    # x_col         = "x_aea",
    # y_col         = "y_aea",
    skip_scale   = FALSE,
    show_plot    = FALSE
  )
  df$scenario = .y
  df
})
str(scenario_dfs, max.level=1)

# all_preds = dplyr::bind_rows(scenario_dfs) %>%
#   mutate(scenario = factor(scenario, levels = c("current", names(temp_shifts))))
all_preds = dplyr::bind_rows(scenario_dfs) 
head(all_preds)
```

We can then quickly compare the spatial ζ₂ surfaces under each future:

``` r
ggplot(all_preds,
       aes(centroid_lon, centroid_lat, fill = pred_zetaExp)) +
       # aes(x_aea, y_aea, fill = pred_zetaExp)) +
  geom_tile() +
  facet_wrap(~ scenario, ncol = 2) +
  scale_fill_viridis_c(direction = -1, name = expression(zeta[2])) +
   geom_sf(data = rsa, fill = NA, color = "black", inherit.aes = FALSE) +
  # geom_sf(data = rsa_aea, fill = NA, color = "black", inherit.aes = FALSE) +
  coord_sf() +
  labs(x = "Longitude", y = "Latitude",
       title = expression("Predicted ζ"[2] * " under current & future scenarios")) +
  theme_minimal() +
  theme(strip.text = element_text(face = "bold"),
        panel.grid = element_blank())
```

------------------------------------------------------------------------
