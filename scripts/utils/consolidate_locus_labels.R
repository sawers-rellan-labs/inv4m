#' Consolidate Locus Labels from Multiple Sources
#'
#' This script creates a master gene label file by combining:
#' 1. WGCNA network genes (FDR < 0.05)
#' 2. Strong DEGs (FDR < 0.05 AND |logFC| > 1.5)
#' 3. Curated labels from phosphorus paper
#' 4. MaizeGDB official symbols
#' 5. PANNZER functional descriptions
#'
#' Method:
#' - Markers (umc, pco, bnlg, etc.) are filtered from locus_label
#' - Real genes are identified by having locus_name in gene_symbol.tab
#' - Priority: curated_label > filtered_symbol > NA
#'
#' Output:
#' - data/locus_labels_master.csv - Full consolidated table
#' - data/locus_labels_gaps.csv - Genes needing manual curation
#'
#' Usage:
#'   source(here::here("scripts/utils/consolidate_locus_labels.R"))
#'   # Or run from command line:
#'   Rscript scripts/utils/consolidate_locus_labels.R
#'
#' Author: Fausto Rodriguez / Claude Code
#' Date: 2026-01-05

library(tidyverse)
library(here)

# === Configuration ===
WGCNA_RUN <- "run_20251231_201332"

# Marker pattern - symbols matching these are filtered from display
# Source: Analysis of data/maizegdb_consensus_map/ (22,272 loci)
# Key insight: Markers have locus_symbol but NO locus_name
MARKER_PATTERN <- paste0(

  "^(umc|pco|bnlg|pza|gpm|csu|php|IDP|TIDP)[0-9]+",
  "|^cl[0-9]+_",
  "|^si[0-9]{5,}",
  "|^LOC[0-9]+",
  "|^AY[0-9]+",
  "|^Zm00001[de]?b?[0-9]+",
  "|^GRMZM"
)

# Marker types documentation:
#   umc  - University of Missouri, Columbia SSR markers
#   pco  - Pioneer Company markers
#   bnlg - Brookhaven National Laboratory (SSR)
#   pza  - Pioneer SNP markers
#   gpm  - Gene primer markers
#   csu  - Colorado State University markers
#   php  - Pioneer hybrid markers
#   IDP  - Insertion-Deletion Polymorphism markers
#   TIDP - Tagged IDP markers
#   cl   - Clone numbers (cDNA libraries)
#   si   - Sequence identifiers
#   LOC  - NCBI gene identifiers
#   AY   - GenBank accessions

cat("=== Locus Label Consolidation ===\n\n")

# === 1. Load Gene Lists ===

cat("Loading gene lists...\n")

# WGCNA network genes
wgcna_path <- here(
 "results/inversion_paper/field_perturbation",
  WGCNA_RUN,
  "02_gene_filter/deg_neighborhood_genes.csv"
)

if (!file.exists(wgcna_path)) {
  stop("WGCNA gene file not found: ", wgcna_path)
}

wgcna_genes <- read_csv(wgcna_path, show_col_types = FALSE)$gene
cat("  WGCNA network genes:", length(wgcna_genes), "\n")

# Effects from differential expression
effects_path <- here(
  "results/inversion_paper/intermediate",
  "predictor_effects_leaf_interaction_model.csv"
)

if (!file.exists(effects_path)) {
  stop("Effects file not found: ", effects_path)
}

effects <- read_csv(effects_path, show_col_types = FALSE) %>%
  filter(predictor == "Inv4m") %>%
  group_by(gene) %>%
  slice(1) %>%
  ungroup()

strong_degs <- effects %>%
  filter(is_strong_DEG == TRUE) %>%
  pull(gene)

cat("  Strong DEGs:", length(strong_degs), "\n")

# Combine unique genes
master_genes <- unique(c(wgcna_genes, strong_degs))
cat("  Combined unique:", length(master_genes), "\n\n")

# === 2. Load Label Sources ===

cat("Loading label sources...\n")

# Curated labels (phosphorus paper)
curated_path <- here("data/selected_DEGs_curated_locus_label_2.csv")
curated <- read_csv(curated_path, show_col_types = FALSE) %>%
  dplyr::select(gene, locus_label_curated = locus_label, desc_curated = desc_merged) %>%
  filter(!is.na(locus_label_curated) & locus_label_curated != "") %>%
  distinct(gene, .keep_all = TRUE)

cat("  Curated labels:", nrow(curated), "genes\n")

# MaizeGDB symbols (deduplicated - take first per gene)
symbols_path <- here("data/gene_symbol.tab")
symbols <- read_tsv(symbols_path, show_col_types = FALSE) %>%
  dplyr::rename(gene = gene_model) %>%
  group_by(gene) %>%
  slice(1) %>%
  ungroup()

cat("  MaizeGDB symbols:", nrow(symbols), "total\n")

# PANNZER descriptions (take first per gene)
pannzer_path <- here("data/PANNZER_DESC.tab")
pannzer <- read_tsv(pannzer_path, show_col_types = FALSE) %>%
  dplyr::rename(gene = gene_model, desc_pannzer = desc) %>%
  group_by(gene) %>%
  slice(1) %>%
  ungroup() %>%
  dplyr::select(gene, desc_pannzer)

cat("  PANNZER descriptions:", nrow(pannzer), "total\n\n")

# === 3. Build Master Table ===

cat("Building master table...\n")

master <- tibble(gene = master_genes) %>%
  # Add MaizeGDB symbol and name
  left_join(symbols, by = "gene") %>%
  # Add PANNZER description
  left_join(pannzer, by = "gene") %>%
  # Add curated label
 left_join(curated, by = "gene") %>%
  # Add effects info
  left_join(
    effects %>% dplyr::select(gene, logFC, adj.P.Val, is_strong_DEG),
    by = "gene"
  )

# === 4. Apply Marker Filtering ===

cat("Applying marker filtering...\n")

master <- master %>%
  mutate(
    # Is symbol a marker?
    is_marker = !is.na(locus_symbol) & grepl(MARKER_PATTERN, locus_symbol),

    # Filter symbol: keep only if has locus_name OR not a marker
    symbol_filtered = case_when(
      !is.na(locus_name) & locus_name != "" ~ locus_symbol,
      !is_marker ~ locus_symbol,
      TRUE ~ NA_character_
    ),

    # Create locus_label: curated > filtered_symbol
    locus_label = coalesce(locus_label_curated, symbol_filtered),

    # Create desc_merged: curated > pannzer
    desc_merged = coalesce(desc_curated, desc_pannzer),

    # Source of label
    label_source = case_when(
      !is.na(locus_label_curated) ~ "curated",
      !is.na(symbol_filtered) ~ "symbol",
      TRUE ~ NA_character_
    )
  ) %>%
  dplyr::select(
    gene, locus_symbol, locus_name, locus_label, label_source,
    desc_pannzer, desc_merged, logFC, adj.P.Val, is_strong_DEG, is_marker
  )

# === 5. Summary ===

cat("\n=== CONSOLIDATION SUMMARY ===\n\n")
cat("Total genes:", nrow(master), "\n")
cat("Unique genes:", n_distinct(master$gene), "\n")
cat("With locus_label:", sum(!is.na(master$locus_label)),
    "(", round(100 * sum(!is.na(master$locus_label)) / nrow(master), 1), "%)\n")
cat("  - From curated:", sum(master$label_source == "curated", na.rm = TRUE), "\n")
cat("  - From symbol:", sum(master$label_source == "symbol", na.rm = TRUE), "\n")
cat("With description:", sum(!is.na(master$desc_merged)),
    "(", round(100 * sum(!is.na(master$desc_merged)) / nrow(master), 1), "%)\n")
cat("Markers filtered:", sum(master$is_marker, na.rm = TRUE), "\n\n")

# === 6. Save Files ===

master_path <- here("data/locus_labels_master.csv")
write_csv(master, master_path)
cat("Saved:", master_path, "\n")

# Gaps: genes with description but no label
gaps <- master %>%
  filter(is.na(locus_label) & !is.na(desc_merged)) %>%
  arrange(desc(abs(logFC)))

gaps_path <- here("data/locus_labels_gaps.csv")
write_csv(gaps, gaps_path)
cat("Saved:", gaps_path, "(", nrow(gaps), "genes need labels)\n\n")

# Show top gaps
cat("=== TOP 10 GAPS (by |logFC|) ===\n")
gaps %>%
  head(10) %>%
  dplyr::select(gene, logFC, desc_merged) %>%
  mutate(desc_merged = str_trunc(desc_merged, 45)) %>%
  print(n = 10)

cat("\nDone.\n")
