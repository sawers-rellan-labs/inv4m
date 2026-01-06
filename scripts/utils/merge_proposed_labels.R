#' Merge Proposed Labels into Master File
#'
#' After reviewing data/locus_labels_proposed_top50.csv, run this script
#' to merge approved labels into the master file.
#'
#' Usage:
#'   Rscript scripts/utils/merge_proposed_labels.R
#'
#' Author: Fausto Rodriguez / Claude Code
#' Date: 2026-01-05

library(tidyverse)
library(here)

cat("=== Merging Proposed Labels ===\n\n")

# Load master file
master <- read_csv(here("data/locus_labels_master.csv"), show_col_types = FALSE)
cat("Master file:", nrow(master), "genes\n")
cat("  With labels:", sum(!is.na(master$locus_label)), "\n")

# Load proposed labels from both files (top50 and remaining)
proposed_top50 <- read_csv(here("data/locus_labels_proposed_top50.csv"), show_col_types = FALSE) %>%
  dplyr::select(gene, proposed_label)
proposed_remaining <- read_csv(here("data/locus_labels_proposed_remaining.csv"), show_col_types = FALSE) %>%
  dplyr::select(gene, proposed_label)

proposed <- bind_rows(proposed_top50, proposed_remaining) %>%
  distinct(gene, .keep_all = TRUE)
cat("Proposed labels:", nrow(proposed), "genes\n")
cat("  From top50:", nrow(proposed_top50), "\n")
cat("  From remaining:", nrow(proposed_remaining), "\n\n")

# Merge: add proposed_label where locus_label is NA
master <- master %>%
  left_join(proposed, by = "gene") %>%
  mutate(
    locus_label = coalesce(locus_label, proposed_label),
    label_source = if_else(
      is.na(label_source) & !is.na(proposed_label),
      "llm_proposed",
      label_source
    )
  ) %>%
  dplyr::select(-proposed_label)

cat("=== AFTER MERGE ===\n")
cat("With labels:", sum(!is.na(master$locus_label)), "\n")
cat("  curated:", sum(master$label_source == "curated", na.rm = TRUE), "\n")
cat("  symbol:", sum(master$label_source == "symbol", na.rm = TRUE), "\n")
cat("  llm_proposed:", sum(master$label_source == "llm_proposed", na.rm = TRUE), "\n")

# Save updated master
write_csv(master, here("data/locus_labels_master.csv"))
cat("\nSaved: data/locus_labels_master.csv\n")

# Update gaps file
gaps <- master %>%
  filter(is.na(locus_label) & !is.na(desc_merged)) %>%
  arrange(desc(abs(logFC)))
write_csv(gaps, here("data/locus_labels_gaps.csv"))
cat("Saved: data/locus_labels_gaps.csv (", nrow(gaps), "remaining gaps)\n")
