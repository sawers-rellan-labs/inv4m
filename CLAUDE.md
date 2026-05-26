# inv4m Project Guide

**Last Updated:** 2026-05-22
**Status:** Phosphorus Paper - Complete ✅ | Inversion Paper - Late Phase 5 / Phase 6 🔶
**Version:** v2.4.0

---

## NEXT SESSION PROMPT (2026-05-26 → next session)

**Read in this order before doing anything:**

1. `agent/inversion_paper/STATE.md` — living state doc. Status snapshot at top: Pass 1 ✅ done, Pass 2 🔶 partial (RE003 ✅, RE004 ✅, RE022 ✅, RE008/RE027/RE030 ⏳), Pass 3 🔶 partial (mapping-rate ✅, Iso-seq parked, RG010 pending, SAM hypothesis pending). The **11-point "Important context the agent must carry forward"** block at the bottom of STATE.md is load-bearing — read it.
2. `~/.claude/projects/.../memory/feedback_avoid_conflation.md` — user's #1 collaboration rule + the anti-oversell directive + the no-pre-reveal-coinage clarification + the Mi21-March-2026 timing + the JMJ subfamily distinctions + the network-analyses-as-candidate-evaluation-tools framing + the no-honest-framing-rhetoric rule. Re-read in full.
3. `agent/inversion_paper/prearxiv_revision/HANDOVER_prearxiv_revision.md` — methodology; status snapshot near top reflects today's progress. The Pass 1 narrative includes a note that the abandoned `user_edits_vs_may04.md` draft sits in `agent/_trash/`; don't reach back for it.
4. `agent/inversion_paper/prearxiv_revision/jmj_discussion_comparison_for_ruben.md` — input artifact for the §JMJ restoration discussion with Ruben. Includes the candidate landscape (jmj2/4 cluster + jmj21 + sec6 + tet2), what was lost in Ruben's RE030, style flags, and three end-state options.

**Active priorities for the day** (ordered by what's blocking what):

1. **§JMJ restoration decision** (RE030 broader). Read the comparison memo. The user wants the pre-Ruben §JMJ subsection (currently commented out at L917–L942) restored — it has the multi-copy → dosage-increase scaffold + methodological honesty + hedged "one candidate among many" framing. Decide: full restore vs hybrid (keep Ruben's Bellegarde 2025 / IPT3 reasoning, drop the hype phrases). This drives several downstream items.
2. **RE008 Intro pre-reveals at L157 + L162 + L165.** Verdict pending on `substantive revision of our understanding` (Jeff JRI005 endorsed, RRA agreed; cutting overrides their agreement — document the call). L165↔L948 duplication still present.
3. **RE027** "exactly the mirror-image" at L811 — one-word soften to "consistent with".
4. **Pass 2 typo sweep**: `withing` → `within` at L134; `acknlowledge` → `acknowledge` at L901.
5. **Iso-seq question**: if Jeff has responded with a specific dataset pointer, look there; otherwise commit to the parsimony case in the §JMJ Discussion.
6. **RG010 synthesis paragraph** — restore-with-neofunctionalization vs leave-cut decision.
7. **SAM hypothesis framing** (JS008 + JRI013): adopt Jeff's wording at current L315 area.

**Hard rules to carry forward (memorize before acting):**

- Anti-oversell governs all framing. Hedged language ("candidate among several", "consistent with", "raises the possibility", "we cannot exclude"). Never definite-the constructions for unmeasured inferences.
- Distinguish "user's own unrevised earlier prose" from "Ruben's late additions" before attributing — example: the `regulatory hub whose perturbation propagates` phrase was the user's own pre-Ruben text (commit `02ceac9`), not Ruben's.
- JMJ subfamilies are not interchangeable: jmj2/4/6/9 (KDM5/JARID1, H3K4 demethylase) vs jmj21 (JHDM2, H3K9 demethylase, IBM1 ortholog). The dosage story is about the former cluster only.
- kWithin label-permutation test is **module-level**, not per-gene. Per-gene kWithin values are descriptive observations only.
- The Mi21 NIL assembly only became available March 2026. Reviewer concerns about "should have used a highland reference" are limitations caveats, not grounds for re-analysis.
- Don't use the term "pre-reveal" — it was an agent overgeneralization, not a real rule. The actual rules are the specific phrasings + the unmeasured-claim test.
- Don't speculate about reviewer-rejection risk at named journals.
- Don't frame the user's work as "dishonest" or use "honest framing" rhetoric. The user has been hedging carefully.

**Tag `anchorhead01` = commit `dc5342a`** is the Pass 1 frozen line-number anchor. If Pass 2 edits drift line numbers materially (more than ~10 lines), re-tag and update the catalogs.

Older session snapshots are in `agent/_trash/inversion_paper/` — historical only.

---

## Project Overview

R/Rmarkdown analysis for two papers on the maize *mexicana* inversion *Inv4m*:

1. **Inversion Paper** — Inv4m effects across field environments (Late Phase 5 / Phase 6 🔶)
2. **Phosphorus Paper** — phosphorus stress × leaf stage, Inv4m interactions (Complete ✅)

**Inversion paper title:** "The teosinte *mexicana* chromosomal inversion *Inv4m* modulates maize flowering time, plant height, and growth regulation gene networks"

### Repository Structure

```
inv4m/
├── agent/                       # AI agent sandbox (git-ignored, ephemeral scratch)
├── scripts/
│   ├── phosphorus_paper/        # Paper 2 notebooks ✅
│   ├── inversion_paper/         # Paper 1 notebooks
│   └── utils/                   # Shared R utilities
├── data/                        # Raw data (git-ignored, in-tree, write-protected)
├── docs/                        # GitHub Pages (HTML reports) + main.tex
├── results/                     # Intermediate outputs (git-ignored)
└── .gitignore
```

---

## Phosphorus Paper Scripts (`scripts/phosphorus_paper/`)

| File | Purpose |
|------|---------|
| `spatial_correction_for_INV4MXP.Rmd` | Spatial correction for phenotypes |
| `differential_expression_leaf_treatment_model.Rmd` | DEG analysis |
| `Lipid_differential_abundance.Rmd` | Differential lipid analysis |
| `PSU2022_growthcurves.Rmd` | Growth curves |
| `PSU2022_ionome.Rmd` | Ionome (concentration + grain/stover ratio) |
| `PSU2022_ionome_content.Rmd` | Ionome content per plant + harvest index |
| `PSU2022_make_transcription_indices.Rmd` | Transcription indices |
| `PSU2022_phenotype_marginal_means.Rmd` | Phenotype marginal means |
| `PSU2022_phenotype_fig1_contrast_test.Rmd` | Figure 1 contrast tests |
| `GO_Enrichment_Analysis_of_DEGs.Rmd` | GO enrichment |
| `KEGG_Pathway_Enrichment_Analysis_of_DEGs.Rmd` | KEGG enrichment |
| `LION_Lipid_Enrichment_Analysis.Rmd` | Lipid enrichment |
| `volcano_plot_analysis.Rmd` | Volcano plots |
| `Annotation_assembly.Rmd` | GO/KEGG/LION enrichment panels |

---

## Inversion Paper Scripts (`scripts/inversion_paper/`)

### Figure 1 (Inv4m delimitation)

| File | Purpose |
|------|---------|
| `plot_Figure_1.Rmd` | Multi-panel assembly |
| `plot_synteny_and_repeats.Rmd` | Panels B–D: repeats, dotplots, breakpoints |
| `plot_genotype_get_correlated_loci.Rmd` | Panels E–F + Fig S1 + Table 1 |
| `make_breakpoint_tables.Rmd` | Tables S1, S2 (breakpoints + knob repeats) |

### Figure 2 (phenotypes + SAM)

| File | Purpose |
|------|---------|
| `plot_Figure_2.Rmd` | 4-panel cowplot assembly (A NILs / B Hybrids / C+D SAMs) |
| `Corrected_phenotype_analysis_PSU2022.Rmd` | PA2022 NIL stage-1/2 (SpATS + lm/emmeans) |
| `Corrected_phenotype_analysis_PSU2024.Rmd` | PA2024 hybrid; focal Inv4_Mi21 vs Inv4_B73 |
| `PSU2024_field_layout.Rmd` | 2×2 P_SQUARE layout inference |
| `SAM_morphology_analysis.Rmd` | SAM DIC microscopy (Alex's primary notebook) |
| `SAM_dabestr_estimation.Rmd` | SAM bootstrap BCa CIs (alternative) |

### GxE (Fig S2/S3, Table S4) + Internodes (Fig S4)

| File | Purpose |
|------|---------|
| `gdd_pre_spatial_correction.Rmd` | GDD lookup |
| `Corrected_phenotype_analysis_PSU2025.Rmd` | PA2025 spatial correction |
| `Corrected_phenotype_analysis_CLY2025_modified.Rmd` | NC2025 spatial correction |
| `inv4mGxE_3_env.Rmd` | GxE figures + Table S4 |
| `internode_analysis.Rmd` | Internode analysis |

### Figure 3 (transcriptomics) + Table 2

| File | Purpose |
|------|---------|
| `differential_expression_leaf_treatment_model.Rmd` | DEG analysis (limma) — Fig 3 MDS, Table S3 |
| `volcano_plot_analysis.Rmd` | Volcano (Fig 3C) |
| `make_manhattan_plots.Rmd` | Manhattans (Fig 3 D/E/G/H) |
| `assemble_figure3_RNAseq.Rmd` | Figure 3 assembly (8 panels) |
| `phenotype_association_filter.Rmd` | Table 2 (FT/PH candidates; applies LD-linked filter) |
| `compare_r2_sliding_window_regions.Rmd` | R² sliding window |
| `sequence_divergence_vs_DE.Rmd` | Mi21–B73 CDS divergence vs DE |

### Figure 4/5 (trans network)

| File | Purpose |
|------|---------|
| `Analyze_MaizeNetome_TransRegulation_network_split.Rmd` | Reference/dataset-specific edge split; renders `Figure_4_C_trans_network.png` and `supp_novel_trans_network_full.png` via webshot (needs `dangerouslyDisableSandbox=true`) |
| `GO_Enrichment_Trans_Network.Rmd` | Network GO enrichment |

### Figure 6 + Fig S5/S6 (WGCNA)

| File | Purpose |
|------|---------|
| `assemble_WGCNA_figure.Rmd` | Figure 6 (WGCNA module perturbation) |
| `WGCNA_module_perturbation_test.Rmd` | Fig S5 — bootstrap support |
| `field_perturbation/` | Consensus pipeline (7 scripts → Fig 6, Fig S6, Table S5) |
| `greenyellow_module_characterization.Rmd` | Table S6 (sec6/pcna2) |

### Figure 7 (JMJ)

| File | Purpose |
|------|---------|
| `Crow2020_reanalysis.Rmd` | Crow 2020 reanalysis |
| `jmj_cluster_expression_boxplot.Rmd` | Fig 7A — cluster + proliferation companions |
| `jmj_5_paralog_split_expression_boxplot.Rmd` | Per-paralog supp (kallisto; not yet in main.tex) |
| `jmj_pink_module_characterization.Rmd` | Table S7 (pink module) |

### ZEAL (Fig S2 — multi-donor flowering replication)

| File | Purpose |
|------|---------|
| `Zeal_Inv4m_flowering_lmm.Rmd` | Lineage corrected boxplots + forest (DTA, DTS, PH) |

---

## Directory Conventions

- `data/` — flat, write-protected (`chmod -R a-w`). Unlock with `chmod -R u+w data/`, drop files, re-lock.
- `results/{paper}/intermediate/` — CSV/RDS processed data
- `results/{paper}/figures/` — PDF, PNG, SVG
- `results/{paper}/tables/` — LaTeX `.tex` ONLY (no CSV)
- `docs/{paper}/` — HTML reports (GitHub Pages)
- `docs/inversion_paper/main.tex` — manuscript (synced to Overleaf manually)
- `agent/` — AI agent sandbox; git-ignored. Subdirs: `agent/inversion_paper/`, `agent/phosphorus_paper/`, `agent/shared/`, `agent/_trash/{paper}/`.

---

## Usage

### Render a notebook

```bash
Rscript scripts/utils/render_notebook.R "scripts/phosphorus_paper/GO_Enrichment_Analysis_of_DEGs.Rmd"
```

Output: `docs/{paper}/{notebook}.html`. Routing is determined by the script's parent directory.

### Notebook YAML preamble

```r
---
title: "Analysis Title"
output:
  html_document: { toc: true, toc_float: true }
knit: (function(input, ...) {
    rmarkdown::render(input,
      output_dir = here::here("docs", "phosphorus_paper"),
      envir = globalenv())
  })
---

library(here)
source(here("scripts", "utils", "setup_paths.R"))
paths <- setup_project_paths("phosphorus_paper")
# paths$data, paths$intermediate, paths$figures, paths$tables
```

### WGCNA Field Perturbation Pipeline

```bash
# Full pipeline (steps 1-7; ~2-3 h production)
./scripts/inversion_paper/run_field_perturbation.sh --yes

# Resume from existing run
./scripts/inversion_paper/run_field_perturbation.sh \
  --resume results/inversion_paper/field_perturbation/run_YYYYMMDD_HHMMSS \
  --start N --end M --yes
```

Steps: 01_data_prep → 02_gene_filter → 03_reference_network → 04_consensus_networks (1000 iter, ~1-2h) → 05_bootstrap_support (~30min) → 06_preservation → 07_module_annotation. Options: `--mode test` (50 iter), `--start N --end M`, `--yes`. Current production run: `run_20251231_201332`.

---

## Git Workflow

### What gets committed

✅ `.Rmd`/`.R` source, `scripts/utils/`, `.md` docs, `.gitignore`
❌ `data/`, `results/`, `agent/`, binaries (`.RDS`, `.RData`, `.csv`, `.pdf`, `.png`)

### Sandbox-aware commands

The sandbox blocks `cd`. Use `git -C <path>` instead.

```bash
git -C "/path/to/inv4m" status
git -C "/path/to/inv4m" -c http.postBuffer=524288000 push origin main   # if SSL/RPC errors
```

---

## Common Issues

- **"Cannot find file"** — check `data/` is unlocked or file is in the right paper subdir.
- **`here::here()` not working** — run from `inv4m/` root, or use `here::i_am(...)`.
- **"Directory does not exist"** — `setup_project_paths()` creates all dirs; verify it's sourced.
- **Notebook fails on missing input** — upstream notebook hasn't been rendered. For DEGs, run `differential_expression_leaf_treatment_model.Rmd` first.
- **R `.onLoad failed for processx` in network notebooks** — sandbox blocks `processx`/`webshot`. Pass `dangerouslyDisableSandbox=true` for those specific renders only.

---

## Notes for AI Assistants

### Session Start Protocol

When starting a new session on this project, **proactively read** `agent/inversion_paper/STATE.md`. That doc holds the active priority, Phase 6 row table, master CSV rename log, and conventions. It is rewritten each session, not appended to. Suggest next actions based on its "Active priority" block.

### Key Conventions

1. **Output routing:**
   - CSV files → `paths$intermediate`
   - LaTeX tables → `paths$tables`
   - Figures → `paths$figures`
   - HTML reports → `docs/{paper}/` (via YAML `knit:` field or render_notebook.R)

2. **Path management:** All scripts use `setup_paths.R` utility with `here::here()`

3. **Agent sandbox:** `agent/` - Temporary work, git-ignored. Organize as `agent/inversion_paper/`, `agent/phosphorus_paper/`, `agent/shared/`, with `agent/_trash/{paper}/` for files whose contents have been absorbed into tracked code or manuscript.

4. **LaTeX formatting:** `main.tex` uses **one-sentence-per-line** (semantic line breaks). When editing LaTeX prose, keep each sentence on its own line — do not wrap to a fixed column width. This produces clean single-line git diffs per sentence change.

### Terminal Commands Rule

When giving multiline terminal commands or instructions to run on HPC/local shell, **always write them to a markdown file in `agent/`** with proper code blocks. Never rely on the user copy-pasting commands from the Claude Code chat window — the formatting breaks and corrupts the commands.

### What to Avoid

- ❌ Don't put CSV files in `tables/` (LaTeX only)
- ❌ Don't create subdirectories in `data/` without first unlocking with `chmod -R u+w data/`; re-lock with `chmod -R a-w data/` after
- ❌ Don't modify analysis logic without explicit request
- ❌ Don't add formatting changes (axis removal, etc.) to analysis scripts - do it in assembly scripts
- ❌ Don't hardcode values that can be calculated from data (e.g., DEG counts)
