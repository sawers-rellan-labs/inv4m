# Create gene expression matrix from kallisto quantification (PSU2022)
# Consolidates transcript-level counts to gene-level expression matrix
#
# Input: kallisto quant_out directory (abundance.tsv per sample)
# Output: Gene × sample count matrix (CSV)
#
# Adapted from maizeRNA/get_xp_matrix_nextflow.R

library(here)
library(dplyr)
library(tidyr)
library(readr)

# Setup paths
source(here("scripts", "utils", "setup_paths.R"))
paths <- setup_project_paths("inversion_paper")

# Kallisto output directory (on mounted server)
quant_dir <- "/Volumes/rsstu/users/r/rrellan/DOE_CAREER/inv4m/PSU2022/kallisto/quant_out/kallisto_quant"

# Check if mounted
if (!dir.exists(quant_dir)) {
  stop("Server not mounted. Mount rsstu first:\n  ",
       "mount_smbfs //frodrig4@rsstu.hpc.ncsu.edu/rsstu /Volumes/rsstu")
}

# Get sample directories
samples <- dir(quant_dir)
cat("Found", length(samples), "samples\n")

# Process each sample - collapse transcripts to genes
cat("Processing samples...\n")
all_exp <- lapply(samples, function(x) {

  # Path: quant_dir/sample/sample/abundance.tsv
  abundance_file <- file.path(quant_dir, x, x, "abundance.tsv")

  if (!file.exists(abundance_file)) {
    warning("File not found: ", abundance_file)
    return(NULL)
  }

  sample_exp <- read.table(
    abundance_file,
    sep = "\t",
    header = TRUE
  )

  # Extract gene ID from transcript ID (remove _T### suffix)
  sample_exp$gene <- factor(sub("_T.+$", "", sample_exp$target_id, perl = TRUE))

  # Sum fractional counts at gene level, then round
  out <- sample_exp %>%
    group_by(gene) %>%
    summarize(counts = round(sum(est_counts)), .groups = "drop")

  cat("  ", x, "- genes:", nrow(out), "\n")
  out$sample <- x
  out
}) %>%
  bind_rows()

# Create gene × sample expression matrix
gene_sample_exp <- all_exp %>%
  pivot_wider(names_from = "sample", values_from = "counts")

# Save expression matrix
output_file <- file.path(paths$intermediate, "PSU2022_gene_expression_matrix.csv")
write_csv(gene_sample_exp, output_file)

# Diagnostics
cat("\n=== Summary ===\n")
cat("Genes quantified:", nrow(gene_sample_exp), "\n")
cat("Samples processed:", ncol(gene_sample_exp) - 1, "\n")
cat("Output file:", output_file, "\n")

# Also save TPM matrix for reference
cat("\nCreating TPM matrix...\n")
all_tpm <- lapply(samples, function(x) {
  abundance_file <- file.path(quant_dir, x, x, "abundance.tsv")
  if (!file.exists(abundance_file)) return(NULL)

  sample_exp <- read.table(abundance_file, sep = "\t", header = TRUE)
  sample_exp$gene <- factor(sub("_T.+$", "", sample_exp$target_id, perl = TRUE))

  out <- sample_exp %>%
    group_by(gene) %>%
    summarize(tpm = sum(tpm), .groups = "drop")

  out$sample <- x
  out
}) %>%
  bind_rows()

gene_sample_tpm <- all_tpm %>%
  pivot_wider(names_from = "sample", values_from = "tpm")

tpm_file <- file.path(paths$intermediate, "PSU2022_gene_tpm_matrix.csv")
write_csv(gene_sample_tpm, tpm_file)
cat("TPM matrix saved:", tpm_file, "\n")
