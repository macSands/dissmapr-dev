# Contributing to dissmapr

First off, thanks for considering contributing to dissmapr!

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](https://b-cubed-eu.github.io/dissmapr/CODE_OF_CONDUCT.md). By
participating in this project you agree to abide by its terms.

## How to contribute

### Report a bug or suggest an enhancement

If you find a bug or have an idea for an enhancement, please [open an
issue](https://github.com/b-cubed-eu/dissmapr/issues/new) and describe:

- For bugs: what you expected to happen, what actually happened, and a
  minimal reproducible example.
- For enhancements: a clear description of the proposed feature and its
  motivation.

### Contribute code

1.  Fork the repository and clone your fork.
2.  Create a new branch from `main` for your changes.
3.  Make your changes, following the coding guidelines below.
4.  Run
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    and ensure there are no errors, warnings, or notes.
5.  Push your branch and open a pull request against `main`.

### Coding guidelines

- Follow the [tidyverse style guide](https://style.tidyverse.org/).
- Use `snake_case` for function and variable names.
- Use explicit namespace calls (`package::function()`) rather than
  `@import`.
- Do not use [`library()`](https://rdrr.io/r/base/library.html),
  [`cat()`](https://rdrr.io/r/base/cat.html), or
  [`print()`](https://rdrr.io/r/base/print.html) in package code.
- Add roxygen2 documentation with `@return` and `@examples` for every
  exported function.
- Add unit tests using testthat for new functionality.

### Development setup

``` r
# install.packages("remotes")
remotes::install_github("b-cubed-eu/dissmapr")
devtools::load_all()
devtools::test()
devtools::check()
```
