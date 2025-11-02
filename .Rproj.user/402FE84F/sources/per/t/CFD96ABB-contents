# data-raw/make-fwi-pr.R
# Small summary table of Fire Weather Index (FWI) probability ratios (PR)
# PR = "times more likely" vs an early-20th-century (~1900–1920) baseline.

library(dplyr)
fwi_pr <- tibble::tibble(
  scenario = c("1920→2019","1920→2019","1920→2°C","1920→2°C"),
  source   = c("ERA5 (observed lower bound)",
               "Models (mean)",
               "Models (mean)",
               "Models (conservative lower bound)"),
  pr_lower = c(4.0, 1.3, 4.0, 4.0),  
  pr_best  = c(NA, 1.8, 8.0, NA),    
  pr_upper = c(NA, NA, NA, NA),
  note     = c(
    "ERA5 indicates ≥4× increase vs early-20th-century baseline",
    "Multi-model mean shows ~80% increase (PR≈1.8), lower bound ≥1.3",
    "Multi-model mean ≈8× at +2°C vs early-20th-century baseline",
    "Conservative lower bound at +2°C"
  )
)

usethis::use_data(fwi_pr, overwrite = TRUE)
