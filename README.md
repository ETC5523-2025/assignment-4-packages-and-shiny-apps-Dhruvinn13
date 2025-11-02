
# fireRiskR

An R package to interactively explore published **Fire Weather Index
(FWI)** probability ratios (PR) for Australian bushfire risk.

**Website (pkgdown):**
<https://etc5523-2025.github.io/assignment-4-packages-and-shiny-apps-Dhruvinn13/>

## Installation

``` r
# install.packages("remotes")
remotes::install_github("ETC5523-2025/assignment-4-packages-and-shiny-apps-Dhruvinn13")
```

## Quick start

``` r
library(fireRiskR)
launch_app()
```

## Data

The package ships a small table `fwi_pr` with published probability
ratios (“times more likely”) for extreme Fire Weather Index events.

``` r
head(fwi_pr)
```
