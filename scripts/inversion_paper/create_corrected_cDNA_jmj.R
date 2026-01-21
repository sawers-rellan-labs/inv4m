# Create corrected cDNA fasta for JMJ cluster kallisto quantification
#
# The V5 annotation incorrectly merges 4 JMJ paralogs into one gene model
# (Zm00001eb191790) with 16 chimeric transcripts. This script creates a
# corrected cDNA fasta where each paralog is a separate entry:
#   - Zm00001eb191790_T001 (jmj9)
#   - Zm00001eb191790_T006 (jmj6)
#   - Zm00001eb191790_T013 (jmj2)
#   - Zm00001eb191790_T017 (psi) - added from V4 annotation
#
# Usage: Run interactively or source with paths configured below

library(Biostrings)
library(here)

# ============================================================================
# Configuration
# ============================================================================

# Reference cDNA (V5) - requires server mount
ref_cdna_path <- "/Volumes/rsstu/users/r/rrellan/sara/ref/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.cdna.all.fa"

# Output path for corrected cDNA - LOCAL (copy to server manually)
output_cdna_path <- here("results", "inversion_paper", "intermediate",
                         "Zea_mays.Zm-B73-REFERENCE-NAM-5.0.cdna.jmj_corrected.fa")

# Clean JMJ candidate sequences (curated from microsynteny analysis)
jmj_candidates_path <- here("data", "jmj_5_candidates_v5_cDNA.fasta")

# ============================================================================
# Check inputs
# ============================================================================

cat("=== Creating corrected JMJ cDNA fasta ===\n\n")

if (!file.exists(ref_cdna_path)) {
  stop("Reference cDNA not found. Is the server mounted?\n  ", ref_cdna_path)
}

if (!file.exists(jmj_candidates_path)) {
  stop("JMJ candidates file not found:\n  ", jmj_candidates_path)
}

# ============================================================================
# Load reference cDNA
# ============================================================================

cat("Loading reference cDNA (this may take a moment)...\n")
ref_cdna <- readDNAStringSet(ref_cdna_path)
cat("  Loaded", length(ref_cdna), "sequences\n")

# Get sequence names (transcript IDs)
seq_names <- names(ref_cdna)

# ============================================================================
# Load clean JMJ candidate sequences
# ============================================================================

cat("\nLoading clean JMJ candidate sequences...\n")
jmj_candidates <- readDNAStringSet(jmj_candidates_path)
cat("  Loaded", length(jmj_candidates), "JMJ sequences:\n")
for (i in seq_along(jmj_candidates)) {
  transcript_id <- sub(" .*", "", names(jmj_candidates)[i])
  cat("    ", transcript_id, ":", width(jmj_candidates)[i], "bp\n")
}

# ============================================================================
# Identify JMJ transcripts to remove from reference
# ============================================================================

# Find all Zm00001eb191790 transcripts in reference (16 chimeric ones)
jmj_indices <- grep("^Zm00001eb191790_T", seq_names)
cat("\nFound", length(jmj_indices), "Zm00001eb191790 transcripts to remove from reference\n")

# ============================================================================
# Prepare clean JMJ sequences for insertion
# ============================================================================

cat("\nPreparing clean JMJ sequences...\n")

# Extract the 4 sequences we want to keep (3 from Zm00001eb191790 + psi)
# T001 (jmj9), T006 (jmj6), T013 (jmj2), and psi (Zm00001d051961_T002 -> T017)

jmj_clean <- jmj_candidates[grep("^Zm00001eb191790_T00[16]|^Zm00001eb191790_T013",
                                  names(jmj_candidates))]

# Get psi and rename to T017
psi_idx <- grep("^Zm00001d051961_T002", names(jmj_candidates))
if (length(psi_idx) > 0) {
  psi_seq <- jmj_candidates[psi_idx]
  # Rename psi to Zm00001eb191790_T017 with updated header
  old_name <- names(psi_seq)
  new_name <- sub("Zm00001d051961_T002", "Zm00001eb191790_T017", old_name)
  new_name <- sub("gene:Zm00001d051961", "gene:Zm00001eb191790", new_name)
  new_name <- sub("chromosome:B73_RefGen_v4:4:175383401:175397333:1",
                  "chromosome:Zm-B73-REFERENCE-NAM-5.0:4:177444828:177452652:1", new_name)
  names(psi_seq) <- new_name
  jmj_clean <- c(jmj_clean, psi_seq)
  cat("  Added psi as Zm00001eb191790_T017\n")
} else {
  warning("Could not find psi (Zm00001d051961_T002) in candidates file!")
}

# Note: jmj4 (Zm00001eb191820) is a separate gene model and stays in reference as-is

cat("\nClean JMJ sequences to add:\n")
for (i in seq_along(jmj_clean)) {
  transcript_id <- sub(" .*", "", names(jmj_clean)[i])
  cat("  ", transcript_id, ":", width(jmj_clean)[i], "bp\n")
}

# ============================================================================
# Build corrected cDNA
# ============================================================================

cat("\nBuilding corrected cDNA fasta...\n")

# Remove ALL Zm00001eb191790 transcripts from reference
other_indices <- setdiff(seq_along(ref_cdna), jmj_indices)
cat("  Removing", length(jmj_indices), "chimeric Zm00001eb191790 transcripts\n")
cat("  Keeping", length(other_indices), "other transcripts from reference\n")

# Combine: other transcripts + clean JMJ (including psi as T017)
corrected_cdna <- c(
  ref_cdna[other_indices],
  jmj_clean
)

cat("  Adding", length(jmj_clean), "clean JMJ transcripts\n")
cat("  Total sequences in corrected cDNA:", length(corrected_cdna), "\n")

# ============================================================================
# Verify JMJ content
# ============================================================================

cat("\nVerifying JMJ transcripts in corrected fasta:\n")
final_jmj <- grep("Zm00001eb191790", names(corrected_cdna), value = TRUE)
for (nm in final_jmj) {
  cat("  ", sub(" .*", "", nm), "\n")
}

# Also check jmj4 is still present
jmj4_present <- any(grepl("Zm00001eb191820", names(corrected_cdna)))
cat("\n  Zm00001eb191820 (jmj4):", ifelse(jmj4_present, "present", "MISSING!"), "\n")

# ============================================================================
# Write output
# ============================================================================

cat("\nWriting corrected cDNA to:\n  ", output_cdna_path, "\n")

# Create output directory if needed
output_dir <- dirname(output_cdna_path)
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

writeXStringSet(corrected_cdna, output_cdna_path)

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Summary ===\n")
cat("Original reference: ", length(ref_cdna), " transcripts\n")
cat("Removed:            ", length(jmj_indices), " chimeric Zm00001eb191790 transcripts\n")
cat("Added:              ", length(jmj_clean), " clean JMJ transcripts\n")
cat("Final:              ", length(corrected_cdna), " transcripts\n")

cat("\nJMJ cluster now has 4 separate gene copies:\n")
cat("  Zm00001eb191790_T001 - jmj9 (first copy)\n")
cat("  Zm00001eb191790_T006 - jmj6 (second copy)\n")
cat("  Zm00001eb191790_T013 - jmj2 (third copy)\n")
cat("  Zm00001eb191790_T017 - psi  (fourth copy, from V4)\n")
cat("  Zm00001eb191820_T001 - jmj4 (separate gene model, unchanged)\n")

cat("\n=== Next Steps ===\n")
cat("1. Copy corrected cDNA to server:\n")
cat("   cp ", output_cdna_path, " \\\n")
cat("      /Volumes/rsstu/users/r/rrellan/DOE_CAREER/inv4m/PSU2022/ref/\n\n")
cat("2. Build kallisto index on HPC:\n")
cat("   kallisto index -i Zm-B73-NAM-5.0.jmj_corrected.idx \\\n")
cat("      /rsstu/users/r/rrellan/DOE_CAREER/inv4m/PSU2022/ref/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.cdna.jmj_corrected.fa\n\n")
cat("3. Re-run kallisto quant with new index\n")
cat("4. Process results with get_expression_matrix_PSU2022.R\n")
