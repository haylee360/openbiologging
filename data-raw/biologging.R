## code to prepare `biologging` dataset
##
## Source data: raw-data/biologging_reviews_completed.csv
##              raw-data/biologging_taxa.csv
##
## Run this script whenever the raw data changes, then re-document and
## re-build the package (devtools::document() + devtools::install()).

library(tidyverse)
library(here)

# ==================================================
# IMPORT
# ==================================================

reviews_df <- read_csv(
  here("data-raw", "raw-data", "biologging_reviews_completed.csv"),
  show_col_types = FALSE
) |>
  janitor::clean_names()

# ==================================================
# CLEAN
# ==================================================

biologging <- reviews_df |>
  mutate(
    # Manuscript type ----
    manuscript_type = fct_collapse(
      manuscript_type,
      S = c("S", "S - Study", "SR"),
      R = c("R", "R - Review"),
      M = c("M", "M - Method"),
      P = c("P", "P - Perspective")
    ) |>
      as.character(),

    # Biologging context ----
    biologging_context = fct_collapse(
      biologging_context,
      W  = c("W", "W - Wild"),
      C  = c("C", "C - Captive"),
      D  = c("D", "D - Domestic"),
      WC = c("WC", "CW", "W,C", "C,W", "W, C", "C, W", "WC - Wild & Captive"),
      WD = c("WD", "DW", "W,D", "D,W", "W, D", "D, W"),
      CD = c("CD", "DC", "C,D", "D,C", "C, D", "D, C")
    ) |>
      as.character(),

    # External data ----
    external_data = str_replace_all(external_data, "y", "Y"),

    # Device category ----
    device_cat = device_cat |>
      str_to_upper() |>
      str_replace_all("[\\s,]+", "") |>
      fct_collapse(
        L   = c("L", "L(DEPTH)"),
        I   = "I",
        E   = c("E", "E?"),
        LI  = c("LI", "IL"),
        LE  = c("LE", "EL"),
        IE  = c("IE", "EI"),
        LIE = c("LIE", "IEL", "EIL", "LEI")
      ) |>
      as.character(),

    # Habitat ----
    habitat = habitat |>
      str_to_upper() |>
      str_replace_all("[\\s,]+", "") |>
      fct_collapse(
        A   = "A",
        M   = "M",
        `T` = "T",
        AM  = c("AM", "MA"),
        AT  = c("AT", "TA"),
        MT  = c("MT", "TM"),
        AMT = "AMT"
      ) |>
      as.character(),

    # Biologging availability ----
    biologging_availability = str_to_upper(biologging_availability),

    # Journal / source ----
    source = str_to_title(source)
  ) |>
  # Drop records with undetermined manuscript type
  filter(manuscript_type != "U")

# ==================================================
# VERIFY
# ==================================================

verification_cols <- c(
  "manuscript_type",
  "biologging_context",
  "external_data",
  "device_cat",
  "habitat",
  "biologging_availability"
)

walk(verification_cols, \(col) {
  cat("──────────────────────────────\n")
  cat("Column:", col, "\n")
  cat(
    "  Before:",
    paste(sort(unique(reviews_df[[col]])), collapse = ", "),
    "\n"
  )
  cat(
    "  After: ",
    paste(sort(unique(biologging[[col]])), collapse = ", "),
    "\n"
  )
})

cat(sprintf("\nFinal row count: %d (dropped %d 'U' manuscript_type rows)\n",
            nrow(biologging),
            nrow(reviews_df) - nrow(biologging)))

# ==================================================
# SAVE
# ==================================================

usethis::use_data(biologging, overwrite = TRUE)
