# Helper functions for compute_orderwise

A suite of helper functions to compute ecological indices used by
[`compute_orderwise()`](https://b-cubed-eu.github.io/dissmapr/reference/compute_orderwise.md),
including geographic distance, dissimilarity metrics, correlations, and
mutual information.

## Details

These helpers are written to be:

- vectorised for the *pairwise* case (two sites/vectors), and

- safe for the *order = 1* case (a single site/vector) by returning a
  sensible scalar (often 0 or NA) instead of erroring.

Additional packages are used via explicit namespace calls: `vegan`
(Bray-Curtis), `entropy` (mutual information), `tibble`/`dplyr`
(pairwise matrix helpers).
