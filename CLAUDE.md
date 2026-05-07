# inv4m Project Guide

**Last Updated:** 2026-05-07
**Status:** Phosphorus Paper - Complete ✅ | Inversion Paper - Phase 6 (pre-submission additions) 🔶
**Version:** v2.2.0

---

## START HERE: Inversion Paper — Phase 6 (Pre-submission additions)

**Current State:** All proofreading + coauthor feedback complete (2026-05-07). Two new figure additions queued before submission: F2 hybrid panel for Figure 2 and a Zeal-population flowering-time supplementary figure. See `agent/inversion_paper/HANDOVER_inversion_paper_revision.md` for the active task list.

**New Title:** "The teosinte *mexicana* chromosomal inversion *Inv4m* modulates maize flowering time, plant height, and growth regulation gene networks"

```
agent/inversion_paper/HANDOVER_inversion_paper_revision.md  # Current state & next actions
agent/inversion_paper/MASTER_PLAN_inversion_paper_revision.md  # Full roadmap
README.md  # Figure/table coverage
```

### Proofreading + Phase 6 Task List (2026-05-07)

| # | Task | Status | Blocked by |
|---|------|--------|------------|
| 1 | Proofread Results 3.1-3.2: Breakpoints + Phenotypes | ✅ done | - |
| 2 | Proofread Results 3.3-3.4: SAM + DEGs + GxE + Internodes | ✅ done | - |
| 3 | Proofread Results 3.5-3.7: WGCNA + Trans-network + JMJ | ✅ done | - |
| 4 | Discussion: Overclaiming pass | ✅ done | #2, #3 |
| 5 | Discussion: Underclaiming pass | ✅ done | #2, #3 |
| 6 | Discussion: Novelty pass | ✅ done | #2, #3 |
| 7 | Discussion: Results-Discussion alignment | ✅ done | #4, #5, #6 |
| 8 | Proofread Methods | ✅ done | - |
| 9 | Proofread Introduction | ✅ done | #7, #8 |
| 10 | Proofread Abstract | ✅ done | #9 |
| 11 | Read aloud: Abstract + Discussion | pending | #10 |
| 12 | Internal peer review: address 18 edits | ✅ done (2026-02-24) | #10 |
| 13 | Overleaf vs repo diff review (22 hunks) | ✅ done (2026-03-23) | #12 |
| 14 | Prose style pass: active voice, no "reveal", site labels | ✅ done (2026-03-12) | #13 |
| 15 | SAM p-values: switch to one-tailed, add flowering literature | ✅ done (2026-03-12) | #14 |
| 16 | Discussion overclaim/framing pass | ✅ done (2026-03-23) | #13 |
| 17 | Overleaf full sync | ✅ done (2026-03-23, tag: overleaf-sync-2026-03-23) | #16 |
| 18 | Rubén full feedback | ✅ done (2026-05-07) | #17 |
| 19 | Coauthor suggestions (all coauthors) | ✅ done (2026-05-07) | #18 |
| 20 | Repo-side site-label rename (PSU→PA, CLY→NC in R scripts) | ✅ done (2026-05-07) | - |
| 21 | Scripts audit + cleanup (delete 25 orphan scripts; rename JMJ notebooks; resolve audit discrepancies) | ✅ done (2026-05-07; commits 988999b → cebb2d2) | - |
| **Phase 6 — pre-submission** | | | |
| 22 | F2 hybrid panel for Figure 2 (new analysis) | not started | - |
| 23 | Zeal-population flowering-time supplementary figure (new analysis) | not started | - |
| 24 | Add `\includegraphics{figs/jmj_paralogs_expression_boxplot.png}` to main.tex supp section + caption + label | pending | - |
| 25 | Re-upload renamed PNGs to Overleaf (PNGs still show old PSU/CLY labels even though main.tex + R scripts updated) | pending | #20 |
| 26 | Bibtex audit of Overleaf .bib (all `\cite{}` keys resolve; spot-check; cover fransz2016, desmarais2017, minow2021, PT HiLo-1.0) | pending | - |
| 27 | Typo fix: "acknlowledge" → "acknowledge" (~main.tex L901) | pending | - |
| 28 | HiFi sequencing provenance: collaborator → co-author, facility → name in Methods | pending | - |
| ❌ | ~~Run BUSCO on Mi21 NIL assembly~~ | dropped (2026-05-07) | - |

### Section 3.2 corrections applied (2026-02-24):
- 126 → 1394 fixed alternate allele markers
- 271 → 512 expressed genes (39 Mb shared introgression)
- 35 → 34 Mb inside run-length, 10.4 → 17 Mb outside run-length
- FDR threshold standardized to 0.005, correlation confirmed Pearson
- B73 seed stock divergence caveat added to Discussion (Liang & Schnable 2016)
- Notebook updated: `plot_genotype_get_correlated_loci.Rmd` (fixed_alternate_alleles, compute_sig_runlength)

**Key threshold change:** "Top DEGs" now = FDR < 0.05 AND |log2FC| > 1.5 (was > 2)

### Prose style and SAM corrections (2026-03-12):
- Site labels renamed throughout: PSU2022→PA2022, PSU2025→PA2025, CLY2025→NC2025
- Section 3.2 subsection title rewritten: "The Inv4m introgression alters flowering time and plant height, with responses that vary by environment"
- All 17 "reveal/revealed/reveals" replaced with varied alternatives
- Passive voice → active voice throughout Results and Discussion
- SAM p-values switched to one-tailed (matching Figure 2C): height p=0.044, h/r p=0.019, shape p=0.018
- SAM-flowering discussion expanded: Danilevskaya 2008, Ku 2008 (SAM elongation = floral competence marker), Leiboff 2015, Thompson 2015 (natural variation)
- Collar diameter → cob diameter
- 4 new bibtex entries as comments (leiboff2015, thompson2015, ku2008, danilevskaya2008)
- Commits: `93af919`, `a6fdadb`
- R script site label rename: ✅ done 2026-05-07 (the historical TODO doc lives in `agent/_trash/inversion_paper/TODO_rename_site_labels.md`)

### Discussion overclaim/framing pass (2026-03-23):
- Guerrero 2016 citation corrected: removed false "proportional to divergence" claim
- Kollar 2025 Mimulus sentences removed (misrepresented paper findings)
- Dobzhansky/Kirkpatrick coadaptation framework replaced with Des Marais et al. 2017
- "coordination among genes" → "rewires native B73 coexpression modules"
- "regulator" → "potential regulator" throughout Results/Methods/Discussion
- Pink module: "most significant connectivity reduction" → "connectivity loss in all 30 genes"
- JMJ reframed as "one candidate among many" with complete-graph caveat
- Added: Fransz 2016 (Arabidopsis FRIGIDA inversion), Said/Khosravi caveat, Minow 2021
- Cross-taxa examples reordered: Arabidopsis → Mimulus → yeast → human
- Removed grab-bag paragraph (Inv9f, CNV recap, inversion size)
- Overleaf fully synced (tag: `overleaf-sync-2026-03-23`)
- 3 new bibtex entries needed: fransz2016, desmarais2017, minow2021
- Pending typo: "acknlowledge" → "acknowledge" (~line 901)

### Peer review edits applied (2026-02-24):
- Abstract: soften attribution ("Inv4m introgression"), add GxE reversal, reframe JMJ as CNV + regulatory suppression, "working model" not "mechanistic chain"
- Results: note Crow 2020 drag reduction (57→24 Mb), reframe OR=1.02, environment-dependent subsection title, internode data within GxE, soften SAM causal language, fix nm→um
- WGCNA: add DEG-input caveat, cite magenta as non-significant counterexample
- Trans-network: "Novel" → "Dataset-specific", explain MaizeNetome overlap as tissue difference
- Discussion: lead JMJ with CNV + ancestral single-copy, "consistent with" not "characteristic of" local adaptation, reciprocal transplant caveat, expanded 4-point limitations
- See: `agent/_trash/inversion_paper/peer_review_inversion_paper.md` and `agent/_trash/inversion_paper/review_response_edits.md` (archived after the audit pass; recover from trash if you need to revisit)

---

## Project Overview

The **inv4m** project analyzes the maize chromosomal inversion Inv4m and its effects on phosphorus stress response. The codebase contains R/Rmarkdown analysis scripts for two papers:

1. **Inversion Paper** - Characterizes Inv4m effects across field environments ✅
2. **Phosphorus Paper** - Analyzes phosphorus stress response and Inv4m interactions ✅

### Repository Structure

```
inv4m/
├── agent/                       # AI agent sandbox (git-ignored, ephemeral scratch)
├── scripts/
│   ├── phosphorus_paper/        # Paper 2 analysis notebooks ✅
│   ├── inversion_paper/         # Paper 1 analysis notebooks
│   └── utils/                   # Shared R utilities
├── data/                        # Raw data and annotations (git-ignored, in-tree real folder, write-protected)
├── docs/                        # GitHub Pages (HTML reports)
│   ├── index.html               # Landing page
│   ├── phosphorus_paper/        # Phosphorus paper reports
│   └── inversion_paper/         # Inversion paper reports + main.tex
├── results/                     # Intermediate outputs (git-ignored)
└── .gitignore                   # Configured for large data/results
```

---

## Phosphorus Paper - Complete ✅

### Scripts (14 Rmd files in `scripts/phosphorus_paper/`)

| File | Purpose | Status |
|------|---------|--------|
| `spatial_correction_for_INV4MXP.Rmd` | Spatial correction for phenotypes | ✅ |
| `differential_expression_leaf_treatment_model.Rmd` | DEG analysis | ✅ |
| `Lipid_differential_abundance.Rmd` | Differential lipid analysis | ✅ |
| `PSU2022_growthcurves.Rmd` | Growth curve analysis | ✅ |
| `PSU2022_ionome.Rmd` | Ionome analysis (concentration + grain/stover ratio) | ✅ |
| `PSU2022_ionome_content.Rmd` | Ionome content per plant + harvest index | ✅ |
| `PSU2022_make_transcription_indices.Rmd` | Transcription indices | ✅ |
| `PSU2022_phenotype_marginal_means.Rmd` | Phenotype marginal means | ✅ |
| `PSU2022_phenotype_fig1_contrast_test.Rmd` | Figure 1 contrast tests | ✅ |
| `GO_Enrichment_Analysis_of_DEGs.Rmd` | GO term enrichment | ✅ |
| `KEGG_Pathway_Enrichment_Analysis_of_DEGs.Rmd` | KEGG pathway enrichment | ✅ |
| `LION_Lipid_Enrichment_Analysis.Rmd` | Lipid enrichment analysis | ✅ |
| `volcano_plot_analysis.Rmd` | Volcano plots | ✅ |
| `Annotation_assembly.Rmd` | GO/KEGG/LION enrichment panels | ✅ |

### Generated Outputs

```
results/phosphorus_paper/
├── intermediate/    # 29 CSV files (processed data)
├── figures/         # 28 files (PDF, PNG, SVG)
└── tables/          # 11 .tex files (LaTeX only)

docs/phosphorus_paper/   # 10 HTML reports (GitHub Pages)
```

### Infrastructure

✅ **setup_paths.R** - Path configuration utility providing:
- `paths$data` - Input data (in-tree real folder, write-protected)
- `paths$intermediate` - Processed CSV/RDS files
- `paths$figures` - Publication figures
- `paths$tables` - LaTeX tables only

✅ **render_notebook.R** - Renders notebooks to `docs/{paper}/` for GitHub Pages

✅ **.gitignore** - Properly configured

---

## Inversion Paper - Phase 6 Pre-submission Additions 🔶

### Scripts (27 Rmd + the field_perturbation pipeline in `scripts/inversion_paper/`)

#### Figure 1 (Inv4m delimitation)

| File | Purpose | Status |
|------|---------|--------|
| `plot_Figure_1.Rmd` | Figure 1 multi-panel assembly | ✅ |
| `plot_synteny_and_repeats.Rmd` | Fig 1 panels B–D: repeat annotation, dotplots, breakpoints | ✅ |
| `plot_genotype_get_correlated_loci.Rmd` | Fig 1 panels E–F + Fig S1 SNP distribution + Table 1 | ✅ |
| `make_breakpoint_tables.Rmd` | Tables S1, S2 (breakpoints across 4 genomes + knob repeats) | ✅ |

#### Figure 2 (phenotypes + SAM)

| File | Purpose | Status |
|------|---------|--------|
| `Corrected_phenotype_analysis_PSU2022.Rmd` | Spatially corrected phenotypes (PA2022 field) | ✅ |
| `SAM_morphology_analysis.Rmd` | SAM DIC microscopy analysis | ✅ |

#### GxE (Fig S2/S3, Table S4)

| File | Purpose | Status |
|------|---------|--------|
| `gdd_pre_spatial_correction.Rmd` | GDD lookup (intermediate for the spatial-correction Rmds) | ✅ |
| `Corrected_phenotype_analysis_PSU2025.Rmd` | PA2025 spatial correction (GxE intermediate) | ✅ |
| `Corrected_phenotype_analysis_CLY2025_modified.Rmd` | NC2025 spatial correction (GxE intermediate) | ✅ |
| `inv4mGxE_3_env.Rmd` | GxE figures S2/S3 + Table S4 | ✅ |
| `internode_analysis.Rmd` | Internode analysis (Fig S4) | ✅ |

#### Figure 3 (transcriptomics) + Table 2

| File | Purpose | Status |
|------|---------|--------|
| `differential_expression_leaf_treatment_model.Rmd` | DEG analysis (limma, plant blocking) — Fig 3 MDS, Table S3 | ✅ |
| `volcano_plot_analysis.Rmd` | Volcano plot (Figure 3 panel C) | ✅ |
| `make_manhattan_plots.Rmd` | Manhattan plots (Fig 3 panels D, E, G, H) | ✅ |
| `assemble_figure3_RNAseq.Rmd` | Figure 3 assembly (8 panels) | ✅ |
| `phenotype_association_filter.Rmd` | Table 2 (FT/PH gene candidates) | ✅ |
| `compare_r2_sliding_window_regions.Rmd` | R² sliding window across regions (intermediate for divergence figure) | ✅ |
| `sequence_divergence_vs_DE.Rmd` | Mi21–B73 CDS divergence vs DE (Supp divergence figure) | ✅ |

#### Figure 5 (trans network)

| File | Purpose | Status |
|------|---------|--------|
| `Analyze_MaizeNetome_TransRegulation_network_split.Rmd` | Trans network reference/dataset-specific edge split | ✅ |
| `GO_Enrichment_Trans_Network.Rmd` | Network GO enrichment + Fig 5 annotation overlay | ✅ |

#### Figure 6 + Fig S5/S6 (WGCNA)

| File | Purpose | Status |
|------|---------|--------|
| `assemble_WGCNA_figure.Rmd` | Figure 6 (WGCNA module perturbation) | ✅ |
| `WGCNA_module_perturbation_test.Rmd` | Figure S5 — bootstrap support comparison (Genotype Response × Leaf Gradient) | ✅ |
| `field_perturbation/` | WGCNA consensus pipeline (7 scripts: 01_data_prep → 07_module_annotation; produces Fig 6 panels, Fig S6, Table S5) | ✅ |
| `greenyellow_module_characterization.Rmd` | Table S6 (greenyellow module DEGs — sec6/pcna2) | ✅ |

#### Figure 7 (JMJ)

| File | Purpose | Status |
|------|---------|--------|
| `Crow2020_reanalysis.Rmd` | Crow 2020 reanalysis (intermediate for JMJ + sequence divergence) | ✅ |
| `jmj_cluster_expression_boxplot.Rmd` | Figure 7 panel A — JMJ cluster expression + cell proliferation companion genes | ✅ |
| `jmj_5_paralog_split_expression_boxplot.Rmd` | Per-paralog supplementary figure (kallisto-corrected reference; planned supp, not yet loaded by main.tex) | 🔶 Phase 6 |
| `jmj_pink_module_characterization.Rmd` | Table S7 (pink module DEGs — JMJ co-expression) | ✅ |

### Generated Outputs

```
results/inversion_paper/
├── intermediate/    # Processed data files
├── figures/         # Publication figures
└── tables/          # LaTeX tables only

docs/inversion_paper/   # HTML reports (GitHub Pages)
```

### Infrastructure

✅ **setup_paths.R** - Path configuration utility providing:
- `paths$data` - Input data (in-tree real folder, write-protected)
- `paths$intermediate` - Processed CSV/RDS files
- `paths$figures` - Publication figures
- `paths$tables` - LaTeX tables only

✅ **render_notebook.R** - Renders notebooks to `docs/{paper}/` for GitHub Pages

✅ **.gitignore** - Properly configured

---

## Success Criteria (All Met ✅)

- [x] Zero hard-coded paths (`~/Desktop/`, `/Users/fvrodriguez/`) in any Rmd file
- [x] All files use `here::here()` for path construction
- [x] All notebooks render successfully from project root
- [x] Clear separation: raw data → `data/`, intermediates → `results/*/intermediate/`, reports → `docs/*/`
- [x] Project runs on any machine without path modifications
- [x] `grep -r "~/Desktop" scripts/phosphorus_paper/*.Rmd` returns nothing

### Figure/Table Coverage (Verified)

All figures and tables in the phosphorus paper have been mapped to their generating scripts. See `README.md` for the complete coverage table.

| Category | Count | Status |
|----------|-------|--------|
| Main Figures | 5 | ✅ |
| Supplementary Figures | 7 | ✅ |
| Supplementary Tables | 7 | ✅ |
| S1 File (Senescence DEGs) | 1 | ✅ |


---

## Directory Structure

### Data Directory

`data/` is a real folder inside the repo (was a symlink to `../inv4mRNA/data` until 2026-05; consolidated in-tree).
- Flat structure with ~80 files at root level + a few subdirs (`papers/`, `ICP - PSU Maize 2023/`, `maizegdb_consensus_map/`)
- Write-protected (`chmod -R a-w`) — to add new inputs, `chmod -R u+w data/` → drop files → re-lock with `chmod -R a-w data/`
- Git-ignored

### Results Directory

```
results/
├── phosphorus_paper/
│   ├── intermediate/    # CSV/RDS processed data files
│   ├── figures/         # PDF, PNG, SVG publication figures
│   └── tables/          # LaTeX tables ONLY (.tex files)
└── inversion_paper/
    └── [same structure]
```

### Docs Directory (GitHub Pages)

```
docs/
├── index.html              # Landing page (root level)
└── phosphorus_paper/       # Paper-specific HTML reports
    ├── GO_Enrichment_Analysis_of_DEGs.html
    └── ...
```

**Key Convention:** `tables/` contains LaTeX (.tex) files only. All CSV outputs go to `intermediate/`. HTML reports go to `docs/{paper}/`.


---

## Usage Instructions

### Rendering Individual Notebooks

```bash
# From project root
Rscript scripts/utils/render_notebook.R "scripts/phosphorus_paper/GO_Enrichment_Analysis_of_DEGs.Rmd"
```

Output will appear in: `docs/phosphorus_paper/GO_Enrichment_Analysis_of_DEGs.html`

### Path Setup in Rmd Files

Every Rmd should start with:

```r
---
title: "Analysis Title"
output:
  html_document:
    toc: true
    toc_float: true
knit: (function(input, ...) {
    rmarkdown::render(
      input,
      output_dir = here::here("docs", "phosphorus_paper"),
      envir = globalenv()
    )
  })
---

# Setup project paths
library(here)
source(here("scripts", "utils", "setup_paths.R"))
paths <- setup_project_paths("phosphorus_paper")

# Now use paths$data, paths$intermediate, paths$figures, etc.
```

### Available Path Variables

After sourcing `setup_paths.R`, use:

- `paths$data` - `data/` (flat, write-protected; `chmod -R u+w data/` to add inputs, then re-lock)
- `paths$intermediate` - `results/phosphorus_paper/intermediate/`
- `paths$figures` - `results/phosphorus_paper/figures/`
- `paths$tables` - `results/phosphorus_paper/tables/`

**IMPORTANT: HTML Report Routing Convention**
- Scripts in `scripts/{paper}/` render to `docs/{paper}/`
- `render_notebook.R` determines output based on script location
- All paper-related analysis scripts live in `scripts/inversion_paper/` or `scripts/phosphorus_paper/`. The deprecated `scripts/shared_paper/` was removed on 2026-05-07.

### Running WGCNA Field Perturbation Pipeline

The WGCNA consensus network pipeline (`scripts/inversion_paper/field_perturbation/`) uses a shell script with checkpoint support:

```bash
# Full pipeline (steps 1-7, ~2-3 hours for production)
./scripts/inversion_paper/run_field_perturbation.sh --yes

# Resume from existing run directory (use cached results)
./scripts/inversion_paper/run_field_perturbation.sh \
  --resume results/inversion_paper/field_perturbation/run_20251231_201332 \
  --start 7 --end 7 --yes

# Run specific steps from checkpoint
./scripts/inversion_paper/run_field_perturbation.sh \
  --resume results/inversion_paper/field_perturbation/run_YYYYMMDD_HHMMSS \
  --start N --end M --yes
```

**Pipeline Steps:**
| Step | Script | Purpose | Typical Runtime |
|------|--------|---------|-----------------|
| 1 | `01_data_prep.Rmd` | Data preparation | ~1 min |
| 2 | `02_gene_filter.Rmd` | Gene filtering (FDR < 0.05) | ~1 min |
| 3 | `03_reference_network.Rmd` | Reference network (power fit) | ~5 min |
| 4 | `04_consensus_networks.Rmd` | Consensus WGCNA (1000 iter) | ~1-2 hours |
| 5 | `05_bootstrap_support.Rmd` | Bootstrap support (1000 iter) | ~30 min |
| 6 | `06_preservation.Rmd` | Preservation analysis | ~10 min |
| 7 | `07_module_annotation.Rmd` | GO enrichment & hub genes | ~5 min |

**Key options:**
- `--mode test` - Quick test run (50 iterations instead of 1000)
- `--resume DIR` - Use existing run directory
- `--start N --end M` - Run only steps N through M
- `--yes` - Skip confirmation prompt

**Current production run:** `results/inversion_paper/field_perturbation/run_20251231_201332/`

---

## Execution Dependencies

Based on previous I/O mapping analysis, notebooks have dependencies:

### Batch 1: Foundational (Generate Intermediates)
These create intermediate files needed by later analyses:
- `differential_expression_leaf_treatment_model.Rmd` → Creates DEG list including Inv4m and Inv4m x Leaf
- Any notebook that generates expression matrices or DEG lists

### Batch 2: Analytic (Consume Intermediates)
These depend on Batch 1 outputs:
- `GO_Enrichment_Analysis_of_DEGs.Rmd` → Needs DEG effects
- `KEGG_Pathway_Enrichment_Analysis_of_DEGs.Rmd` → Needs DEG effects
- `PSU2022_make_transcription_indices.Rmd` → Needs expression matrix
- `PSU2022_growthcurves.Rmd` → Needs spatially corrected phenotypes
- `PSU2022_ionome.Rmd` → Needs spatially corrected phenotypes
- `LION_Lipid_Enrichment_Analysis.Rmd` → Needs LION enrichment results
- `volcano_plot_analysis.Rmd` → Needs DEG effects

### Batch 3: Synthesis
High-level summaries and multi-panel figures combining multiple analyses.

---

## Common Issues & Solutions

### Issue: "Cannot find file"

**Cause:** File not yet moved from Desktop to `data/` structure
**Solution:** Check file location, move to appropriate place under `data/`

### Issue: "here::here() not working"

**Cause:** Working directory not set to project root
**Solution:** Always run from `inv4m/` project root, or use `here::i_am("scripts/phosphorus_paper/script.Rmd")`

### Issue: "Directory does not exist"

**Cause:** Output directory not created
**Solution:** `setup_project_paths()` creates all directories automatically; verify it's sourced

### Issue: Notebook fails partway through

**Cause:** Missing intermediate file from upstream notebook
**Solution:** Check execution dependencies, run Batch 1 notebooks first

---

## Git Workflow

### What Gets Committed

✅ **Track these:**
- All `.Rmd` and `.R` source files
- `scripts/utils/` utilities
- Documentation (`.md` files)
- `.gitignore` configuration

❌ **Never commit:**
- `data/` directory (large, git-ignored)
- `results/` directory (generated outputs, git-ignored)
- `agent/` (agent sandbox, git-ignored)
- Binary files (`.RDS`, `.RData`, `.csv`, `.pdf`, `.png`)

### Sandbox-aware git commands

The working directory is inside a sandbox that restricts `cd`. Always use `git -C <repo-path>` instead of `cd <repo-path> && git ...` for all git operations.

```bash
# CORRECT — use -C flag
git -C "/path/to/inv4m" status
git -C "/path/to/inv4m" add scripts/file.R
git -C "/path/to/inv4m" commit -m "message"

# WRONG — cd is blocked by sandbox
cd /path/to/inv4m && git status
```

### Typical Workflow

```bash
# After refactoring Rmd files
git -C "/path/to/inv4m" add scripts/phosphorus_paper/*.Rmd
git -C "/path/to/inv4m" add scripts/utils/setup_paths.R
git -C "/path/to/inv4m" commit -m "refactor: standardize paths in phosphorus_paper notebooks"

# Push changes
git -C "/path/to/inv4m" push origin main
```

---

## Progress Tracking

### Phosphorus Paper ✅ Complete
- [x] Audit all hard-coded paths (172 paths identified)
- [x] Map file dependencies (180+ files classified)
- [x] Create execution roadmap (3 batches defined)
- [x] Configure .gitignore properly
- [x] Create render_notebook.R utility
- [x] Create directory structure
- [x] Migrate Desktop files to data/
- [x] Create setup_paths.R utility
- [x] Refactor all 11 phosphorus_paper Rmds
- [x] Test rendering all notebooks
- [x] Validate outputs in correct directories
- [x] Tag release v1.0.0

### Inversion Paper 🔶 Phase 6 Pre-submission Additions

**Completed Phases:**
- [x] Phase 1: Critical Updates (limma model, DEGs, Figure 1-3)
- [x] Phase 2: Network Analysis (Figure 5, Figure 6 WGCNA, GO enrichment)
- [x] Phase 3: Phenotype Integration (SAM data in Figure 2)
- [x] Phase 4: Methods & Results Writing (all 7 Results sections, Discussion, Abstract, Title)
- [x] Phase 5: Review & Polish (proofreading, peer review, Discussion overclaim/framing pass, Overleaf sync, coauthor feedback)
- [x] Audit + cleanup (2026-05-07): scripts audit, deletions, JMJ rename, S1/S5 producer fixes; commits `988999b` → `cebb2d2`

**Current Phase 6: Pre-submission additions**
- [ ] **F2 hybrid panel for Figure 2** (new analysis)
- [ ] **Zeal-population flowering-time supplementary figure** (new analysis)
- [ ] Add `\includegraphics{figs/jmj_paralogs_expression_boxplot.png}` to main.tex supp section + caption + label
- [ ] Re-upload renamed PNGs to Overleaf (PSU/CLY → PA/NC labels)
- [ ] Bibtex audit of Overleaf .bib (full pass)
- [ ] Read-aloud proofreading: Abstract + Discussion
- [ ] Typo fix: "acknlowledge" → "acknowledge" (~main.tex L901)
- [ ] HiFi sequencing provenance: collaborator → co-author, facility → name in Methods

**See:** `agent/inversion_paper/HANDOVER_inversion_paper_revision.md` (active task list) and `agent/inversion_paper/MASTER_PLAN_inversion_paper_revision.md` (roadmap).

---

## Notes for AI Assistants

### Session Start Protocol

When starting a new session on this project, **proactively read**:
1. `agent/inversion_paper/HANDOVER_inversion_paper_revision.md` - Current state and next actions
2. `agent/inversion_paper/MASTER_PLAN_inversion_paper_revision.md` - Full revision roadmap

Then suggest next actions based on the handover document.

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
