## code to prepare `taxa` dataset
##
## Source data: raw-data/biologging_taxa.csv
##
## Cleaning proceeds in four stages:
##   1. Genus-level typos (exact string match → corrected genus)
##   2. Species-level typos (genus + species pair match → corrected species)
##   3. Formatting artifacts (author suffixes, multi-word genus fields, etc.)
##   4. Final filter: remove flagged review rows and NA entries
##
## Review lists (rows that need a manual decision before inclusion) are printed
## at the end but NOT written into the package dataset. Re-add them once you
## have resolved each category.
##
## Run this script whenever the raw data changes, then re-document and
## re-build the package (devtools::document() + devtools::install()).

library(tidyverse)
library(here)

# ==================================================
# IMPORT
# ==================================================

taxa_raw <- read_csv(
  here("data-raw", "raw-data", "biologging_taxa.csv"),
  show_col_types = FALSE
)

# ==================================================
# STAGE 1: GENUS-LEVEL TYPOS
# Exact string match on trimmed genus field → corrected genus.
# ==================================================

taxa_stage1 <- taxa_raw |>
  mutate(
    genus = case_when(
      str_trim(genus) == "Camela"        ~ "Camelus",       # Camelus ferus
      str_trim(genus) == "Canus"         ~ "Canis",         # Canis lupus
      str_trim(genus) == "Carcharhinu"   ~ "Carcharhinus",  # truncated
      str_trim(genus) == "Carcharinus"   ~ "Carcharhinus",  # missing 'h'
      str_trim(genus) == "Phsyster"      ~ "Physeter",      # Physeter macrocephalus
      str_trim(genus) == "Physester"     ~ "Physeter",
      str_trim(genus) == "Doimedea"      ~ "Diomedea",      # Diomedea exulans
      str_trim(genus) == "Loxodona"      ~ "Loxodonta",     # Loxodonta africana
      str_trim(genus) == "Ocrinus"       ~ "Orcinus",       # Orcinus orca
      str_trim(genus) == "Ragnifer"      ~ "Rangifer",      # Rangifer tarandus
      str_trim(genus) == "Rupicara"      ~ "Rupicapra",     # Rupicapra rupicapra
      str_trim(genus) == "Ursos"         ~ "Ursus",         # Ursus arctos
      str_trim(genus) == "Ales"          ~ "Alces",         # Alces alces
      str_trim(genus) == "Elaphas"       ~ "Elephas",       # Elephas maximus
      str_trim(genus) == "Natador"       ~ "Natator",       # Natator depressus
      str_trim(genus) == "Prionance"     ~ "Prionace",      # Prionace glauca
      str_trim(genus) == "halacrocorax"  ~ "Phalacrocorax", # lowercase h
      str_trim(genus) == "Capreoulus"    ~ "Capreolus",     # Capreolus capreolus
      str_trim(genus) == "Chrysemy"      ~ "Chrysemys",     # Chrysemys picta
      str_trim(genus) == "Circu"         ~ "Circus",        # Circus pygargus
      str_trim(genus) == "Phalacocorax"  ~ "Phalacrocorax",
      str_trim(genus) == "Phocartos"     ~ "Phocarctos",    # Phocarctos hookeri
      str_trim(genus) == "Squalu"        ~ "Squalus",       # Squalus acanthias
      TRUE                               ~ genus
    )
  )

# ==================================================
# STAGE 2: SPECIES-LEVEL TYPOS
# Matched on BOTH genus and species to avoid cross-genus collisions.
# ==================================================

taxa_stage2 <- taxa_stage1 |>
  mutate(
    species = case_when(
      genus == "Anas"          & species == "acutais"          ~ "acuta",
      genus == "Anas"          & species == "phatyrhynchos"    ~ "platyrhynchos",
      genus == "Anas"          & species == "platurhynchos"    ~ "platyrhynchos",
      genus == "Anas"          & species == "quequedula"       ~ "querquedula",
      genus == "Antrostomus"   & species == "vociferous"       ~ "vociferus",
      genus == "Balaenoptera"  & species == "musuclus"         ~ "musculus",
      genus == "Bos"           & species == "tarus"            ~ "taurus",
      genus == "Bos"           & species == "taurs"            ~ "taurus",
      genus == "Castor"        & species == "fbre"             ~ "fiber",
      genus == "Capreolus"     & species == "capreoulus"       ~ "capreolus",
      genus == "Cervus"        & species == "elaphu"           ~ "elaphus",   # truncated
      genus == "Cervus"        & species == "elephas"          ~ "elaphus",
      genus == "Cervus"        & species == "elephus"          ~ "elaphus",
      genus == "Chrysocyon"    & species == "brachyrus"        ~ "brachyurus",
      genus == "Cuculus"       & species == "canoras"          ~ "canorus",
      genus == "Erinaceus"     & species == "europeaus"        ~ "europaeus",
      genus == "Eubalaena"     & species == "australia"        ~ "australis",
      genus == "Globicephala"  & species == "macrohynchus"     ~ "macrorhynchus",
      genus == "Gyps"          & species == "ruepellii"        ~ "rueppellii",
      genus == "Inia"          & species == "geofrensis"       ~ "geoffrensis",
      genus == "Jynx"          & species == "torquila"         ~ "torquilla",
      genus == "Lepidochelys"  & species == "kempi"            ~ "kempii",
      genus == "Megaptera"     & species == "novaeanglea"      ~ "novaeangliae",
      genus == "Meleagris"     & species == "gallapavo"        ~ "gallopavo",
      genus == "Mirounga"      & species == "angustirostr"     ~ "angustirostris", # truncated
      genus == "Mirounga"      & species == "leonine"          ~ "leonina",
      genus == "Odocoileus"    & species == "virginianu"       ~ "virginianus",
      genus == "Odocoileus"    & species == "coriacea"         ~ "virginianus", # NOTE: confirm against source ref
      genus == "Odocoileu"     & species == "virginianus"      ~ "virginianus", # truncated genus handled below
      genus == "Oves"          & species == "aries"            ~ "aries",
      genus == "Ovies"         & species == "aries"            ~ "aries",
      genus == "Ovis"          & species == "ares"             ~ "aries",
      genus == "Procellaria"   & species == "westlandia"       ~ "westlandica",
      genus == "Pygoscelis"    & species == "antarctica"       ~ "antarcticus",
      genus == "Pygoscelis"    & species == "papus"            ~ "papua",
      genus == "Rupicapra"     & species == "rupicara"         ~ "rupicapra",
      genus == "Salmo"         & species == "truta"            ~ "trutta",
      genus == "Sarkidrionis"  & species == "melanotos"        ~ "melanotos",   # genus fixed below
      genus == "Thalassarche"  & species == "melanophrys"      ~ "melanophris", # IOC spelling
      genus == "Elephas"       & species == "maximas"          ~ "maximus",
      genus == "Ursus"         & species == "actos"            ~ "arctos",
      genus == "Ursus"         & species == "maritimu"         ~ "maritimus",
      genus == "Ursus"         & species == "maritinus"        ~ "maritimus",
      genus == "Canis"         & species == "lupus familiarus" ~ "lupus familiaris",
      genus == "Canis"         & species == "lupis"            ~ "lupus",       # safety net for stage-3 rows
      TRUE                                                     ~ species
    )
  ) |>
  # Additional genus fixes not cleanly handled by the stage-1 case_when
  mutate(
    genus = case_when(
      str_trim(genus) == "Sarkidrionis" ~ "Sarkidiornis", # transposed letters
      str_trim(genus) == "Cervis"       ~ "Cervus",
      str_trim(genus) == "Oves"         ~ "Ovis",
      str_trim(genus) == "Ovies"        ~ "Ovis",
      str_trim(genus) == "Odocoileu"    ~ "Odocoileus",   # truncated
      TRUE                              ~ genus
    )
  )

# ==================================================
# STAGE 3: FORMATTING ARTIFACTS
# Author suffixes, backtick remnants, multi-word genus fields,
# parenthetical synonyms, capitalised epithets, and remaining genus typos.
# ==================================================

taxa_stage3 <- taxa_stage2 |>
  mutate(
    # Strip trailing author suffix " L." from species field
    species = str_remove(species, "\\s+L\\.\\s*$"),

    # Remove stray backtick from genus (e.g. "Rangifer `")
    genus = str_remove(genus, "\\s*`\\s*$"),

    # Multi-word genus: "Calonectris x" — hybrid; clean genus, keep species
    genus = if_else(str_trim(genus) == "Calonectris x", "Calonectris", genus),

    # Multi-word genus: "Anser cygnoides" — species smuggled into genus field
    species = if_else(
      str_trim(genus) == "Anser cygnoides",
      str_trim(word(genus, 2)),
      species
    ),
    genus = if_else(str_trim(genus) == "Anser cygnoides", "Anser", genus),

    # Multi-word genus: "Connochaetes taurinus" — species already correct
    genus = if_else(
      str_trim(genus) == "Connochaetes taurinus",
      "Connochaetes",
      genus
    ),

    # Multi-word genus: "Canis lupis" — species epithet in genus field
    species = case_when(
      str_trim(genus) == "Canis lupis" &
        str_trim(species) == "familiaris" ~ "lupus familiaris",
      str_trim(genus) == "Canis lupis"   ~ "lupus",
      TRUE                               ~ species
    ),
    genus = if_else(str_trim(genus) == "Canis lupis", "Canis", genus),

    # Parenthetical synonym: "Tectus" species stored as "(= Trochus) niloticus"
    species = if_else(
      str_trim(genus) == "Tectus",
      str_remove(species, "^\\(=\\s*Trochus\\)\\s*"),
      species
    ),

    # Capitalised epithet: "Neophocaena Phocaenoides"
    species = if_else(
      str_trim(genus) == "Neophocaena" & str_trim(species) == "Phocaenoides",
      "phocaenoides",
      species
    ),

    # "Denrocygna" — missing 'd'
    genus = if_else(str_trim(genus) == "Denrocygna", "Dendrocygna", genus),

    # "Pheobastria" → "Phoebastria" (transposed letters)
    genus = if_else(str_trim(genus) == "Pheobastria", "Phoebastria", genus),

    # "Baleaenoptera" → "Balaenoptera" (extra 'e')
    genus = if_else(str_trim(genus) == "Baleaenoptera", "Balaenoptera", genus),

    # Final trim
    genus   = str_trim(genus),
    species = str_trim(species)
  )

# ==================================================
# VERIFICATION: Print what changed between raw and cleaned
# ==================================================

changed <- taxa_stage3 |>
  filter(
    genus   != taxa_raw$genus |
      species != taxa_raw$species
  ) |>
  left_join(
    taxa_raw |> select(id, genus_orig = genus, species_orig = species),
    by = "id"
  ) |>
  filter(genus != genus_orig | species != species_orig) |>
  select(id, genus_orig, species_orig, genus_clean = genus, species_clean = species) |>
  arrange(genus_clean, species_clean)

cat(sprintf("\nRows changed: %d\n", nrow(changed)))
print(changed, n = Inf)

# ==================================================
# REVIEW LISTS
# These rows need a manual decision — they are NOT auto-corrected above and
# are excluded from the final package dataset until resolved.
# ==================================================

# A. Reclassifications / nomenclatural conflicts
review_waterfowl <- taxa_stage3 |>
  filter(genus == "Anas" & species %in%
           c("penelope", "falcata", "strepera", "clypeata",
             "querquedula", "cyanoptera", "formosa"))

review_shearwaters <- taxa_stage3 |>
  filter(genus == "Puffinus" & species %in%
           c("griseus", "carneipes", "tenuirostris"))

review_albatross <- taxa_stage3 |>
  filter(genus == "Diomedea" & species == "melanophris")

review_cranes <- taxa_stage3 |>
  filter(genus == "Grus" & species %in% c("rubicunda", "canadensis"))

review_seals <- taxa_stage3 |>
  filter(genus == "Phoca" & species %in% c("sibirica", "hispida"))

# B. Domestic / feral / subspecies standardisation
review_canis <- taxa_stage3 |>
  filter(genus == "Canis" & species %in%
           c("familiaris", "lupus familiaris", "lupus familiarus",
             "lupus domesticus", "dingo", "lupus dingo"))

review_felis <- taxa_stage3 |>
  filter(genus == "Felis" & species %in%
           c("silvestris catus", "silvestris", "catus"))

review_capra <- taxa_stage3 |>
  filter(genus == "Capra" & species %in%
           c("hircus", "aegagrus hircus"))

review_bos <- taxa_stage3 |>
  filter(genus == "Bos" & species %in%
           c("indicus", "taurus indicus"))

# C. Taxonomic splits
review_alces <- taxa_stage3 |>
  filter(genus == "Alces" & species == "americanus")

# D. Hybrids
review_hybrids <- taxa_stage3 |>
  filter(
    (genus == "Calonectris" & species == "diomedea" & id == "authier2013") |
      (genus == "Clanga"      & species == "clanga x pomarina") |
      (genus == "Ovis"        & species %in%
         c("gmelini musimon x sp.", "gmelini musimon \u00d7 sp."))
  )

# E. Genus-only / spp. entries
review_spp <- taxa_stage3 |>
  filter(
    (genus == "Calyptorhynchus" & species == "spp")  |
      (genus == "Pteropus"        & species == "spp.") |
      (genus == "Papio"           & species == "spp.") |
      (genus == "Chelonodis"      & species == "sp.")  |
      (genus == "Odocoileus"      & species == "spp.")
  )

# F. Unresolvable — need to check original paper
review_unresolvable <- taxa_stage3 |>
  filter(
    (genus == "Cerorhinca" & species == "olivaceus") | # likely C. monocerata
      (genus == "Salmo"      & species == "orhidanus")   # unclear — check source
  )

# G. NA species (silently excluded from phylogeny — listed for awareness)
review_na <- taxa_stage3 |>
  filter(is.na(genus) | genus == "NA" | is.na(species) | species == "NA")

# Combined review tibble
review_all <- bind_rows(
  review_waterfowl   |> mutate(review_reason = "waterfowl reclassification"),
  review_shearwaters |> mutate(review_reason = "shearwater reclassification"),
  review_albatross   |> mutate(review_reason = "albatross reclassification"),
  review_cranes      |> mutate(review_reason = "crane reclassification"),
  review_seals       |> mutate(review_reason = "seal reclassification"),
  review_canis       |> mutate(review_reason = "Canis domestic/feral standardisation"),
  review_felis       |> mutate(review_reason = "Felis domestic standardisation"),
  review_capra       |> mutate(review_reason = "Capra domestic standardisation"),
  review_bos         |> mutate(review_reason = "Bos indicus/taurus overlap"),
  review_alces       |> mutate(review_reason = "Alces americanus taxonomic split"),
  review_hybrids     |> mutate(review_reason = "hybrid"),
  review_spp         |> mutate(review_reason = "genus-only / spp. entry"),
  review_unresolvable|> mutate(review_reason = "unresolvable — check source paper")
) |>
  distinct() |>
  arrange(review_reason, genus, species)

cat(sprintf("\nTotal rows flagged for review: %d\n", nrow(review_all)))
cat(sprintf("Unique study IDs flagged:      %d\n", n_distinct(review_all$id)))
print(review_all |> select(id, genus, species, review_reason), n = Inf)

# ==================================================
# FINAL CLEAN DATASET
# Excludes review rows and NA entries.
# Re-add resolved rows by moving them out of the review lists above.
# ==================================================

taxa <- taxa_stage3 |>
  anti_join(review_all, by = c("id", "genus", "species")) |>
  filter(
    !is.na(genus),
    !is.na(species),
    genus   != "NA",
    species != "NA"
  )

cat(sprintf(
  "\ntaxa: %d rows (from %d raw; %d review rows and %d NA rows excluded)\n",
  nrow(taxa),
  nrow(taxa_raw),
  nrow(review_all),
  nrow(review_na)
))

# ==================================================
# SAVE
# ==================================================

usethis::use_data(taxa, overwrite = TRUE)
