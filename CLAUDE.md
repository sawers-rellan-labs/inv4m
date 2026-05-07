# inv4m Project Guide

**Last Updated:** 2026-02-24
**Status:** Phosphorus Paper - Complete ✅ | Inversion Paper - Proofreading 🔶
**Version:** v2.1.0

---

## START HERE: Inversion Paper Final Proofreading

**Current State:** Peer review response edits APPLIED (2026-02-24). Manuscript proofreading ongoing.

**New Title:** "The teosinte *mexicana* chromosomal inversion *Inv4m* modulates maize flowering time, plant height, and growth regulation gene networks"

```
agent/HANDOVER_inversion_paper_revision.md  # Current state & next actions
agent/MASTER_PLAN_inversion_paper_revision.md  # Full roadmap
README.md  # Figure/table coverage
```

### Proofreading Task List (2026-02-24)

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
| 18 | Rubén full feedback | pending | #17 |
| 19 | Coauthor suggestions | pending | #18 |

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
- R script site label rename TODO: `agent/TODO_rename_site_labels.md`

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
- See: `agent/peer_review_inversion_paper.md` and `review_response_edits.md`

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
│   ├── inversion_paper/         # Paper 1 analysis notebooks (future)
│   ├── shared_paper/            # Foundation scripts used by BOTH papers
│   └── utils/                   # Shared R utilities
├── data/                        # Raw data and annotations (git-ignored, symlink)
├── docs/                        # GitHub Pages (HTML reports)
│   ├── index.html               # Landing page
│   └── phosphorus_paper/        # Paper-specific reports
├── results/                     # Intermediate outputs (git-ignored)
└── .gitignore                   # Configured for large data/results
```

---

## Phosphorus Paper - Complete ✅

### Scripts (12 Rmd files in `scripts/phosphorus_paper/`)

| File | Purpose | Status |
|------|---------|--------|
| `spatial_correction_for_INV4MXP.Rmd` | Spatial correction for phenotypes | ✅ |
| `differential_expression_leaf_treatment_model.Rmd` | DEG analysis | ✅ |
| `Lipid_differential_abundance.Rmd` | Differential lipid analysis | ✅ |
| `PSU2022_growthcurves.Rmd` | Growth curve analysis | ✅ |
| `PSU2022_ionome.Rmd` | Ionome analysis | ✅ |
| `PSU2022_make_transcription_indices.Rmd` | Transcription indices | ✅ |
| `PSU2022_phenotype_marginal_means.Rmd` | Phenotype marginal means | ✅ |
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
- `paths$data` - Input data (symlinked)
- `paths$intermediate` - Processed CSV/RDS files
- `paths$figures` - Publication figures
- `paths$tables` - LaTeX tables only

✅ **render_notebook.R** - Renders notebooks to `docs/{paper}/` for GitHub Pages

✅ **.gitignore** - Properly configured

---

## Inversion Paper - Phase 4 Results Writing 🔶

### Scripts (in `scripts/inversion_paper/`)

| File | Purpose | Status |
|------|---------|--------|
| `plot_genotype_get_correlated_loci.Rmd` | SNP distribution and correlation | ✅ |
| `Corrected_phenotype_analysis_PSU2022.Rmd` | Corrected phenotype analysis | ✅ |
| `differential_expression_leaf_treatment_model.Rmd` | DEG analysis | ✅ |
| `Analyze_MaizeNetome_TransRegulation.Rmd` | Trans coexpression network | ✅ |
| `get_WGCNA_modules.Rmd` | WGCNA network analysis | ✅ |
| `GO_Enrichment_Trans_Network.Rmd` | Network GO analysis | ✅ |
| `Crow2020_reanalysis.Rmd` | Crow 2020 reanalysis | ✅ |
| `make_manhattan_plots.Rmd` | Manhattan plots (Fig 3 D,E,G,H) | ✅ |
| `volcano_plot_analysis.Rmd` | Volcano plot (Fig 3 C / Fig 4) | ✅ |
| `assemble_figure3_RNAseq.Rmd` | Figure 3 assembly (8 panels) | ✅ |
| `model_comparison_plant_blocking.Rmd` | Model comparison utility | ✅ |
| `Analyze_MaizeNetome_TransRegulation_network_split.Rmd` | Network ref/novel split | ✅ |
| `assemble_WGCNA_figure.Rmd` | WGCNA Figure 6 assembly | ✅ |
| `jmj_cluster_expression_boxplot.Rmd` | JMJ + cell proliferation expression | ✅ |
| `SAM_morphology_analysis.Rmd` | SAM DIC microscopy analysis | ✅ |
| `plot_synteny_and_repeats.Rmd` | Fig 1 Panels B–D: repeat annotation, dotplots, breakpoints | ✅ |
| `field_perturbation/` | WGCNA consensus pipeline (7 scripts) | ✅ |

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
- `paths$data` - Input data (symlinked)
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
├── inversion_paper/
│   └── [same structure]
└── shared_paper/
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

- `paths$data` - `data/` (flat, symlinked directory - read-only)
- `paths$intermediate` - `results/phosphorus_paper/intermediate/`
- `paths$figures` - `results/phosphorus_paper/figures/`
- `paths$tables` - `results/phosphorus_paper/tables/`

**IMPORTANT: HTML Report Routing Convention**
- Scripts in `scripts/{paper}/` render to `docs/{paper}/`
- `render_notebook.R` determines output based on script location
- All paper-related analysis scripts should be in `scripts/inversion_paper/` or `scripts/phosphorus_paper/`
- Do NOT put paper-specific scripts in `scripts/shared_paper/` - move them to the appropriate paper folder

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
**Solution:** Check file location, move to appropriate `data/phosphorus_paper/` or `data/shared_paper/`

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

### Inversion Paper 🔶 Phase 4 In Progress

**Completed Phases:**
- [x] Phase 1: Critical Updates (limma model, DEGs, Figure 1-4)
- [x] Phase 2: Network Analysis (Figure 5, Figure 6 WGCNA, GO enrichment)
- [x] Phase 3: Phenotype Integration (SAM data in Figure 2)

**Current Phase 4: Methods & Results Writing**
- [x] All main figures complete (1-8)
- [x] All supplementary figures complete (S1-S5)
- [x] All tables complete (1-2, S1-S4)
- [x] Methods sections mostly complete
- [ ] **Results narrative incomplete** - does not match recent analysis (est. 8-10 hours)
- [ ] **Discussion section** - not written
- [ ] MaizeNetome validation for WGCNA analysis (methods)

**Phase 5: Review & Polish (not started)**
- [ ] Internal consistency check
- [ ] Final proofreading
- [ ] USER: Add preservation table/figure to Overleaf

**See:** `agent/MASTER_PLAN_inversion_paper_revision.md` and `TODO_05_results_writing.md` for detailed roadmap

---

## Notes for AI Assistants

### Session Start Protocol

When starting a new session on this project, **proactively read**:
1. `agent/HANDOVER_inversion_paper_revision.md` - Current state and next actions
2. `agent/MASTER_PLAN_inversion_paper_revision.md` - Full revision roadmap

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
- ❌ Don't create subdirectories in `data/` (it's a symlink)
- ❌ Don't modify analysis logic without explicit request
- ❌ Don't add formatting changes (axis removal, etc.) to analysis scripts - do it in assembly scripts
- ❌ Don't hardcode values that can be calculated from data (e.g., DEG counts)
