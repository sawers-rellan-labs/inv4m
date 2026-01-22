#!/usr/bin/env Rscript
#
# Extract Kallisto Counts Matrix
#
# This script extracts the full counts matrix from kallisto quantification
# outputs and saves it to the intermediate folder. Run this script when
# the server is mounted to cache the data locally.
#
# Usage:
#   Rscript scripts/inversion_paper/extract_kallisto_counts_matrix.R
#
# Requires:
#   - Server mounted at /Volumes/rsstu/
#   - Kallisto outputs in quant_out_jmj_corrected/kallisto_quant/
#
# Output:
#   - results/inversion_paper/intermediate/PSU2022_kallisto_jmj_corrected_counts.csv
#

library(here)
library(tidyverse)

# Setup paths
source(here("scripts", "utils", "setup_paths.R"))
paths <- setup_project_paths("inversion_paper")

# Configuration
# Try multiple possible mount points
possible_paths <- c(

  "/Volumes/DOE_CAREER/inv4m/PSU2022/kallisto/quant_out_jmj_corrected/kallisto_quant",
  "/Volumes/rsstu/users/r/rrellan/DOE_CAREER/inv4m/PSU2022/kallisto/quant_out_jmj_corrected/kallisto_quant"
)

quant_dir <- NULL
for (p in possible_paths) {
  if (dir.exists(p)) {
    quant_dir <- p
    break
  }
}

output_file <- file.path(paths$intermediate, "PSU2022_kallisto_jmj_corrected_counts.csv")

# Check server mount
if (is.null(quant_dir)) {
  stop(
    "Server not mounted or kallisto output directory not found.\n",
    "  Tried paths:\n",
    paste("    -", possible_paths, collapse = "\n"), "\n",
    "  Please mount the server and try again."
  )
}

cat("=== KALLISTO COUNTS MATRIX EXTRACTION ===\n\n")
cat("Source:", quant_dir, "\n")
cat("Output:", output_file, "\n\n")

# Get sample directories
samples <- dir(quant_dir)
cat("Found", length(samples), "samples\n")

# Extract abundance data from all samples
cat("Extracting abundance data...\n")

all_abundance <- lapply(samples, function(x) {
  abundance_file <- file.path(quant_dir, x, x, "abundance.tsv")

  if (!file.exists(abundance_file)) {
    warning("File not found: ", abundance_file)
    return(NULL)
  }

  abundance <- read.table(abundance_file, sep = "\t", header = TRUE)
  abundance$sample <- x
  abundance
}) %>%
  bind_rows()

cat("Extracted", n_distinct(all_abundance$target_id), "transcripts x",
    n_distinct(all_abundance$sample), "samples\n")

# Create wide counts matrix (transcripts x samples)
cat("Creating wide counts matrix...\n")

full_counts_matrix <- all_abundance %>%
  select(target_id, sample, est_counts) %>%
  pivot_wider(names_from = sample, values_from = est_counts)

cat("Matrix dimensions:", nrow(full_counts_matrix), "x", ncol(full_counts_matrix), "\n")

# Save counts matrix
cat("Saving to:", basename(output_file), "\n")
write_csv(full_counts_matrix, output_file)

# Report file size
file_size_mb <- file.size(output_file) / 1e6
cat("\nFile size:", round(file_size_mb, 1), "MB\n")

cat("\n=== EXTRACTION COMPLETE ===\n")
cat("The counts matrix is now cached locally.\n")
cat("JMJ analysis scripts can run without server access.\n")
