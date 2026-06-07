#!/usr/bin/env Rscript
# =============================================================================
# Supplementary LaTeX table: Iso-seq evidence for the 5 JMJ cluster candidates
# =============================================================================
# Builds tab::jmj_isoseq from the Wang 2020 (B73 RefGen_v4) reanalysis outputs.
# Each candidate is mapped to its v4 gene and its collapsed FLNC group (PB.X);
# per-tissue B73-inbred full-length read counts and isoform counts are joined in.
#
# The candidate <-> v4 <-> PB.X mapping is the curated assignment from
# 06_report.Rmd (best-hit-by-bitscore is misleading for >=99% identical
# paralogs; the diagnostic is the spatial separation of the PB.X groups).
# jmj6 and jmj2 share PB.11787 (a ~43 kb collapsed span over both v4 genes,
# ~24 kb apart) so their FL counts are pooled; the jmj2 row is left blank to
# avoid double counting (see dagger note).
#
# INPUTS  : results/inversion_paper/intermediate/isoseq_jmj_05_PBX_FL_b73_only.tsv
#           results/inversion_paper/intermediate/isoseq_jmj_03_PBX_groups_at_cluster.tsv
# OUTPUT  : results/inversion_paper/tables/isoseq_jmj_candidate_evidence.tex
# USAGE   : Rscript scripts/inversion_paper/isoseq_jmj/07_candidate_evidence_table.R
# =============================================================================

suppressPackageStartupMessages({library(here); library(tidyverse)})
source(here("scripts", "utils", "setup_paths.R"))
paths <- setup_project_paths("inversion_paper")

inter <- paths$intermediate
fl   <- read_tsv(file.path(inter, "isoseq_jmj_05_PBX_FL_b73_only.tsv"), show_col_types = FALSE)
grp  <- read_tsv(file.path(inter, "isoseq_jmj_03_PBX_groups_at_cluster.tsv"), show_col_types = FALSE)

# curated candidate -> v4 -> PB.X mapping (genomic 5'->3' order), from 06_report.Rmd
map <- tribble(
  ~label_tex,        ~transcript,              ~v4_gene,          ~PB_X,        ~shared,
  "\\jmjix",         "Zm00001eb191790\\_T001", "Zm00001d051959",  "PB.11785",   FALSE,
  "\\textit{$\\psi$}","Zm00001d051961\\_T002", "Zm00001d051961",  "PB.11786",   FALSE,
  "\\jmjvi",         "Zm00001eb191790\\_T006", "Zm00001d051963",  "PB.11787",   FALSE,
  "\\jmjii",         "Zm00001eb191790\\_T013", "Zm00001d051964",  "PB.11787",   TRUE,
  "\\jmjiv",         "Zm00001eb191820\\_T001", "Zm00001d051965",  "PB.11788",   FALSE
)

tab <- map %>%
  left_join(select(grp, PB_X, n_isoforms), by = "PB_X") %>%
  left_join(fl, by = "PB_X")

fmt_pbx <- function(pbx, shared) ifelse(shared, paste0("\\texttt{", pbx, "}$^\\dagger$"),
                                                paste0("\\texttt{", pbx, "}$^\\dagger$"))
# only the two PB.11787 rows get the dagger
tab <- tab %>%
  mutate(pbx_tex = ifelse(PB_X == "PB.11787",
                          paste0("\\texttt{", PB_X, "}$^\\dagger$"),
                          paste0("\\texttt{", PB_X, "}")))

# build one LaTeX row per candidate; jmj2 (shared) row blanks the numeric cells
row_tex <- function(r) {
  if (isTRUE(r$shared)) {
    cells <- c(r$label_tex, paste0("\\texttt{", r$transcript, "}"),
               paste0("\\texttt{", r$v4_gene, "}"), r$pbx_tex,
               "shared", "---", "---", "---", "shared")
  } else {
    cells <- c(r$label_tex, paste0("\\texttt{", r$transcript, "}"),
               paste0("\\texttt{", r$v4_gene, "}"), r$pbx_tex,
               r$n_isoforms, r$embryo, r$endosperm, r$root, r$total_B73_inbred)
  }
  paste(cells, collapse = " & ")
}
body <- paste0(vapply(seq_len(nrow(tab)), function(i) row_tex(tab[i, ]), character(1)),
               " \\\\", collapse = "\n")

caption <- paste0(
  "\\textbf{Full-length (Iso-seq) transcript evidence for the five B73 \\jmjii/\\jmjiv ",
  "cluster paralogs.} Reanalysis of the Wang et al. 2020 maize Iso-seq atlas ",
  "(collapsed transcripts mapped on B73 RefGen\\_v4) \\citep{wang2020}. Each v5 ",
  "candidate is mapped to its v4 gene model and to the collapsed full-length, ",
  "non-concatemer (FLNC) group (\\texttt{PB.X}); columns give the FLNC read count ",
  "in the three B73 inbred samples (embryo, endosperm, root) and the number of ",
  "collapsed isoforms in the group. The four \\texttt{PB.X} groups are spatially ",
  "non-overlapping along the cluster, consistent with at least four independent ",
  "transcription units in B73 rather than alternative isoforms of a single v5 locus. ",
  "Iso-seq tissues are embryo, endosperm, and root; leaf and SAM are not sampled."
)

note <- paste0(
  "\\begin{flushleft}\\footnotesize $^\\dagger$\\texttt{PB.11787} (a $\\sim$43 kb ",
  "collapsed span) encompasses both \\jmjvi\\ (\\texttt{Zm00001d051963}) and \\jmjii\\ ",
  "(\\texttt{Zm00001d051964}), $\\sim$24 kb apart. The collapsed annotation cannot ",
  "distinguish fuzzy-collapse of two separate units, a template-switch chimera, or a ",
  "single long transcription unit; \\jmjvi\\ and \\jmjii\\ counts are pooled and the ",
  "\\jmjii\\ row blanked to avoid double counting. This affects only the upper bound ",
  "(four versus five paralog-level units), not the falsifier ($\\geq$two). \\textit{$\\psi$} ",
  "is transcribed (three root FLNC reads) but its transcript carries a genome-encoded ",
  "frameshift premature stop (B73 v5 chr4:177{,}445{,}822--177{,}445{,}824) that truncates ",
  "the JMJ open reading frame, consistent with a pseudogene.\\end{flushleft}"
)

tex <- paste0(
  "\\begin{table}[!ht]\n",
  "\\caption{", caption, "}\n",
  "\\label{tab::jmj_isoseq}\n",
  "\\centering\n\\small\n",
  "\\begin{tabular}{@{}llllrrrrr@{}}\n",
  "\\toprule\n",
  "\\textbf{Candidate} & \\textbf{v5 transcript} & \\textbf{v4 gene} & ",
  "\\textbf{FLNC group} & \\textbf{Isoforms} & \\textbf{Embryo} & ",
  "\\textbf{Endosperm} & \\textbf{Root} & \\textbf{Total} \\\\\n",
  "\\midrule\n",
  body, "\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  note, "\n",
  "\\end{table}\n"
)

outfile <- file.path(paths$tables, "isoseq_jmj_candidate_evidence.tex")
writeLines(tex, outfile)
cat("Wrote:", outfile, "\n\n")
cat(tex)
