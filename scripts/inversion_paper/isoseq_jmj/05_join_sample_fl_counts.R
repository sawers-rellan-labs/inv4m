#!/usr/bin/env Rscript
# Join per-sample FL counts + IsoPhase haplotypes to the cluster transcripts.
#
# Inputs:
#   results/intermediate/cluster_transcripts.bed   (from script 03)
#   results/intermediate/cluster_PBX_groups.txt    (from script 03)
#   data/zenodo/F1maize.FINAL.demux_FL_count.txt   (Zenodo)
#   data/queries/sample_metadata.tsv               (sample -> tissue, genotype)
#   data/supp/42003_2020_805_MOESM3_ESM.xlsx       (IsoPhase Supp Data 1)
#
# Outputs (results/tables/):
#   05_cluster_FL_counts.tsv       per-transcript x per-sample FL counts
#   05_PBX_FL_totals.tsv           per PB.X totals (B73 / Ki11 / F1) x tissue
#   05_PBX_FL_b73_only.tsv         B73-inbred-only FL counts per PB.X per tissue
#   05_isophase_cluster.tsv        IsoPhase rows whose PacBio locus is at the cluster

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr); library(xml2)
})

# Robust working-dir setup
this_file <- tryCatch(normalizePath(sys.frames()[[1]]$ofile), error = function(e) NA)
if (is.na(this_file)) {
  args <- commandArgs(trailingOnly = FALSE)
  fkey <- "--file="
  m <- grep(fkey, args, value = TRUE)
  if (length(m)) this_file <- sub(fkey, "", m[1])
}
root <- if (!is.na(this_file)) normalizePath(file.path(dirname(this_file), "..")) else getwd()
setwd(root)

tbl_dir <- "results/tables"
int_dir <- "results/intermediate"
dir.create(tbl_dir, showWarnings = FALSE, recursive = TRUE)

# -- cluster transcript inventory --
hits <- read_tsv(file.path(int_dir, "cluster_transcripts.bed"),
                 col_names = c("chr","start","end","transcript_id","PB_X","strand"),
                 col_types = "ciicccc", show_col_types = FALSE)
cluster_pbx <- readLines(file.path(int_dir, "cluster_PBX_groups.txt"))

# -- sample metadata --
meta <- read_tsv("data/queries/sample_metadata.tsv", show_col_types = FALSE)

# -- demux FL count matrix --
fl <- read_csv("data/zenodo/F1maize.FINAL.demux_FL_count.txt", show_col_types = FALSE)
colnames(fl)[1] <- "transcript_id"

fl_cluster <- hits %>%
  select(transcript_id, PB_X, chr, start, end, strand) %>%
  inner_join(fl, by = "transcript_id")
write_tsv(fl_cluster, file.path(tbl_dir, "05_cluster_FL_counts.tsv"))

# Long form for grouping
sample_cols <- setdiff(colnames(fl_cluster),
                       c("transcript_id","PB_X","chr","start","end","strand"))
long <- fl_cluster %>%
  select(transcript_id, PB_X, all_of(sample_cols)) %>%
  pivot_longer(all_of(sample_cols), names_to = "sample", values_to = "FL") %>%
  left_join(meta, by = "sample")

# Per PB.X x tissue x genotype totals
pbx_total <- long %>%
  group_by(PB_X, tissue, genotype) %>%
  summarise(FL = sum(FL), .groups = "drop") %>%
  pivot_wider(names_from = c(tissue, genotype), values_from = FL, values_fill = 0)
write_tsv(pbx_total, file.path(tbl_dir, "05_PBX_FL_totals.tsv"))

# B73-inbred only: keep only EM1, END1, R1
pbx_b73 <- long %>%
  filter(is_b73_inbred == "yes") %>%
  group_by(PB_X, tissue) %>%
  summarise(FL_B73_inbred = sum(FL), .groups = "drop") %>%
  pivot_wider(names_from = tissue, values_from = FL_B73_inbred, values_fill = 0) %>%
  mutate(total_B73_inbred = rowSums(across(where(is.numeric))))
write_tsv(pbx_b73, file.path(tbl_dir, "05_PBX_FL_b73_only.tsv"))

# -- IsoPhase supplementary --
extract_isophase <- function(path) {
  tmp <- tempfile(); dir.create(tmp); unzip(path, exdir = tmp)
  ns <- c(a = "http://schemas.openxmlformats.org/spreadsheetml/2006/main")
  ss_xml <- read_xml(file.path(tmp, "xl", "sharedStrings.xml"))
  strings <- xml_text(xml_find_all(ss_xml, ".//a:si", ns))
  sheets <- c(embryo = "sheet1.xml", root = "sheet2.xml", endosperm = "sheet3.xml")
  do.call(rbind, lapply(names(sheets), function(t) {
    sxml <- read_xml(file.path(tmp, "xl", "worksheets", sheets[[t]]))
    rows <- xml_find_all(sxml, ".//a:row", ns)
    parse_row <- function(r) {
      cs <- xml_find_all(r, "./a:c", ns)
      refs <- xml_attr(cs, "r")
      letters_vec <- sub("[0-9]+$", "", refs)
      col_idx <- vapply(letters_vec, function(letters) {
        s <- 0L
        for (ch in strsplit(letters, "")[[1]]) s <- s*26L + (utf8ToInt(ch) - 64L)
        s
      }, integer(1))
      vals <- vapply(seq_along(cs), function(i) {
        v <- xml_text(xml_find_first(cs[[i]], "./a:v", ns))
        if (is.na(v) || identical(v,"")) return(NA_character_)
        if (identical(xml_attr(cs[[i]], "t"), "s")) strings[as.integer(v)+1] else v
      }, character(1))
      out <- rep(NA_character_, max(col_idx, 1L))
      out[col_idx] <- vals
      out
    }
    rows_v <- lapply(rows, parse_row)
    ncol <- max(vapply(rows_v, length, integer(1)))
    rows_v <- lapply(rows_v, function(r) c(r, rep(NA_character_, ncol - length(r))))
    m <- do.call(rbind, rows_v)
    df <- as.data.frame(m[-1,,drop=FALSE], stringsAsFactors = FALSE)
    colnames(df) <- m[1,]
    df$tissue <- t
    df
  }))
}

isophase <- extract_isophase("data/supp/42003_2020_805_MOESM3_ESM.xlsx")
isophase$PB_X <- sub("_.*$", "", isophase[["PacBio locus"]])
iso_cluster <- isophase[isophase$PB_X %in% cluster_pbx, , drop = FALSE]
write_tsv(iso_cluster, file.path(tbl_dir, "05_isophase_cluster.tsv"))

cat("Cluster PB.X groups:        ", paste(cluster_pbx, collapse=", "), "\n")
cat("IsoPhase rows at cluster:   ", nrow(iso_cluster), "\n\n")

cat("Per-PB.X FL totals (B73 inbred only):\n")
print(as.data.frame(pbx_b73))
cat("\nPer-PB.X x (tissue,genotype) FL totals:\n")
print(as.data.frame(pbx_total))
if (nrow(iso_cluster) > 0) {
  cat("\nIsoPhase rows at the cluster:\n")
  print(iso_cluster[, c("RefGen_V4 gene","PacBio locus","phase0","phase1","tissue","PB_X")])
}
