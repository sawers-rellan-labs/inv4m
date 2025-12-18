# inv4m Project Refactoring Guide

**Last Updated:** 2025-12-18
**Status:** Phase 1 - Path Standardization (In Progress)
**Current Focus:** Phosphorus Paper Rmd Files

---

## Project Overview

The **inv4m** project analyzes the maize chromosomal inversion Inv4m and its effects on phosphorus stress response. The codebase contains R/Rmarkdown analysis scripts for two planned papers:

1. **Inversion Paper** - Characterizes Inv4m effects across field environments
2. **Phosphorus Paper** - Analyzes phosphorus stress response and Inv4m interactions

### Repository Structure

```
inv4m/
├── scripts/
│   ├── 00_agent_work/          # AI agent sandbox (git-ignored)
│   ├── 01_hpc_pipelines/        # SLURM/HPC processing scripts
│   ├── 02_genomics_foundation/  # Mapping and synteny
│   ├── inversion_paper/         # Paper 1 analysis notebooks
│   ├── phosphorus_paper/        # Paper 2 analysis notebooks
│   ├── shared_paper/            # Foundation scripts used by BOTH papers
│   └── utils/                   # Shared R utilities
├── data/                        # Raw data and annotations (git-ignored)
├── results/                     # All outputs (git-ignored)
└── .gitignore                   # Configured for large data/results
```

---

## Current State (2025-12-18)

### Problem Statement

**The codebase is not reproducible or portable.** All 11 Rmd files in `scripts/phosphorus_paper/` use hard-coded desktop paths:

- **100% hard-coded paths** like `~/Desktop/predictor_effects_leaf_interaction_model.csv`
- **20+ input files** scattered on Desktop in various subdirectories
- **No project-relative pathing** - breaks on any other machine
- **Mix of path styles** - `~/Desktop/`, `/Users/fvrodriguez/Desktop/`, `../data/`
- **Outputs to Desktop** - figures, tables, RDS objects all saved to `~/Desktop/figure_panels/`

**Messiness Score:** 8/10 (VERY MESSY)

### What Exists Now

#### Scripts (11 Rmd files in `scripts/phosphorus_paper/`)

| File | Purpose | Status |
|------|---------|--------|
| `GO_Enrichment_Analysis_of_DEGs.Rmd` | GO term enrichment | Uses desktop paths |
| `KEGG_Pathway_Enrichment_Analysis_of_DEGs.Rmd` | KEGG pathway enrichment | Uses desktop paths |
| `LION_Lipid_Enrichment_Analysis.Rmd` | Lipid enrichment analysis | Uses desktop paths |
| `PSU2022_Build_ photosynthesis_sensescencc_indices.Rmd` | Photosynthesis indices | Uses desktop paths |
| `PSU2022_growthcurves.Rmd` | Growth curve analysis | Uses desktop paths |
| `PSU2022_ionome.Rmd` | Ionome analysis | Uses desktop paths |
| `PSU2022_make_transcription_indices.Rmd` | Transcription indices | Uses desktop paths |
| `PSU2022_phenotype_marginal_means.Rmd` | Phenotype marginal means | Uses desktop paths |
| `PSU_pheno_phosohorus.Rmd` | Phosphorus phenotypes | Uses desktop paths |
| `differential_lipid_analysis_leaf_treatment_interaction_model.Rmd` | Differential lipid analysis | Uses desktop paths |
| `volcano_plot_analysis.Rmd` | Volcano plots | Uses desktop paths |

#### Current Data Organization

**Flat `data/` directory** with ~30 files at root level:
- RNA-seq expression matrices
- Phenotype CSVs
- Gene annotations
- MS-Dial lipid data
- Metadata files

**Existing `results/` structure:**
```
results/
├── phosphorus_paper/
│   ├── intermediate/      # Some files exist
│   └── reports/           # Knitted HTML outputs
└── inversion_paper/
    ├── intermediate/
    └── reports/
```

#### Infrastructure Already in Place

✅ **render_notebook.R** - Generic rendering utility that:
- Takes any Rmd path as argument
- Auto-detects paper folder from path
- Outputs to `results/{paper}/reports/`
- Creates directories if needed

✅ **.gitignore** - Properly configured to:
- Ignore `data/` and `results/` directories
- Ignore large binary files (RDS, RData, CSV, PDF, PNG)
- Ignore agent sandbox (`scripts/00_agent_work/`)
- Track only source code (Rmd, R, sh scripts)

---

## Refactoring Goals

### Primary Objective

**Make the phosphorus paper analysis fully reproducible** by implementing project-root-relative paths using `here::here()`.

### Success Criteria

- [ ] Zero hard-coded paths (`~/Desktop/`, `/Users/fvrodriguez/`) in any Rmd file
- [ ] All files use `here::here()` for path construction
- [ ] All notebooks render successfully from project root
- [ ] Clear separation: raw data → `data/`, intermediates → `results/*/intermediate/`, reports → `results/*/reports/`
- [ ] Project runs on any machine without path modifications
- [ ] `grep -r "~/Desktop" scripts/phosphorus_paper/*.Rmd` returns nothing

### Non-Goals (Out of Scope)

- ❌ Refactoring inversion_paper scripts (separate phase)
- ❌ Optimizing analysis code or adding features
- ❌ Changing statistical methods or adding documentation
- ❌ Over-engineering with unnecessary subdirectories

---

## Planned Directory Structure

### Simplified Paper-Level Organization

```
data/
├── phosphorus_paper/        # Phosphorus-specific input data (~20 files)
├── inversion_paper/          # Inversion-specific input data (~15 files)
└── shared_paper/             # Cross-paper resources (GO, gene xrefs, GOMAP)

results/
├── phosphorus_paper/
│   ├── intermediate/         # Generated data (normalized_expression, DEG effects, etc.)
│   ├── figures/              # Publication figures (PDF, PNG, SVG)
│   ├── tables/               # Publication tables (CSV, LaTeX)
│   └── reports/              # Knitted HTML/PDF notebooks
├── inversion_paper/
│   └── [same structure]
└── shared_paper/
    ├── intermediate/
    └── reports/
```

**Design Philosophy:**
- **Flat paper-level folders** - no deep nesting by data type
- **Mirrors script structure** - `scripts/phosphorus_paper/` ↔ `data/phosphorus_paper/`
- **Clear data flow** - raw data → intermediate results → final reports
- **Shared resources extracted** - GO annotations, gene cross-references in `shared_paper/`

---

## Implementation Strategy

### Phase 1: Setup & Migration (Current Phase)

**Focus:** phosphorus_paper only

1. **Create directory structure**
   - `data/phosphorus_paper/`, `data/shared_paper/`
   - `results/phosphorus_paper/{intermediate,figures,tables}/`

2. **Migrate files from Desktop**
   - Categorize 20+ Desktop files as phosphorus-specific vs. shared
   - Copy to appropriate `data/` subdirectories
   - Backup Desktop before migration: `tar -czf ~/Desktop_backup_$(date +%F).tar.gz ~/Desktop/`

3. **Create path configuration utility**
   - `scripts/utils/setup_paths.R` with `setup_project_paths()` function
   - Returns named list of standardized paths using `here::here()`
   - Every Rmd sources this at the top

### Phase 2: Rmd Refactoring

**Pattern:**

**BEFORE:**
```r
effects_df <- read.csv("~/Desktop/predictor_effects_leaf_interaction_model.csv")
TERM2GENE <- readRDS("/Users/fvrodriguez/Desktop/GOMAP_maize_B73_NAM5/TERM2GENE.rds")
ggsave("~/Desktop/figure_panels/go_panel.pdf", plot = p)
```

**AFTER:**
```r
library(here)
source(here("scripts", "utils", "setup_paths.R"))
paths <- setup_project_paths("phosphorus_paper")

effects_df <- read.csv(file.path(paths$data, "predictor_effects_leaf_interaction_model.csv"))
TERM2GENE <- readRDS(file.path(paths$shared, "GOMAP_TERM2GENE.rds"))
ggsave(file.path(paths$figures, "go_panel.pdf"), plot = p)
```

**Refactor order** (by dependency):
1. Standalone files (enrichment analyses, volcano plots)
2. Phenotype analyses (growthcurves, ionome)
3. Expression index calculations
4. Differential lipid analysis

### Phase 3: Validation

1. Test render each Rmd individually
2. Verify outputs land in correct `results/` subdirectories
3. Check no hard-coded paths remain
4. Test on clean repository clone
5. Update documentation

---

## File Classification (Phosphorus Paper)

### Input Files (To be moved to `data/`)

**Phosphorus-Specific** → `data/phosphorus_paper/`
- `predictor_effects_leaf_interaction_model.csv` - DEG analysis results
- `selected_DEGs_curated_locus_label_2.csv` - Curated gene annotations
- `selected_DEGs_leaf_interaction_model.csv` - Final DEG list
- `DEG_effects.csv` - Effect sizes
- `normalized_expression_logCPM.rda` - Normalized expression matrix
- `PSU2022_spatially_corrected_both_treatments.csv` - Phenotypes
- `22_NCS_PSU_LANGEBIO_FIELDS_PSU_P_field.csv` - Field data
- `PSU_RawData_MSDial_NewStdInt_240422.csv` - MS-Dial lipid data
- `LION-enrichment_LowPVSHighP.csv` - LION enrichment
- `inv4mRNAseq_metadata.csv` - RNA-seq metadata
- `PSU-PHO22_ms_order.csv` - MS injection order

**Shared Resources** → `data/shared_paper/`
- `GOMAP_maize_B73_NAM5/TERM2NAME.rds` - GO term names
- `GOMAP_maize_B73_NAM5/TERM2GENE_Fattel_2024_full.rds` - GO mappings
- `B73_gene_xref/B73v3_to_B73v5.tsv` - Gene version mapping
- `B73_gene_xref/B73v4_to_B73v5.tsv` - Gene version mapping
- `corncyc_pathways.20251021` - CornCyc pathways
- `slim_to_plot.csv` - GO slim filter
- `SAG_orthologs.csv` - Senescence genes
- `staygreen_network_sekhon2019.csv` - Staygreen genes
- `natural_senescence.csv` - Natural senescence genes

### Intermediate Files (Generated by notebooks)

**To be written to** `results/phosphorus_paper/intermediate/`
- Normalized expression objects (RDS)
- Statistical model results (CSV)
- Filtered gene lists (CSV)
- Cached plot objects (RDS)
- Processed data frames (CSV)

### Final Outputs

**Figures** → `results/phosphorus_paper/figures/`
- PDF, PNG, SVG publication figures

**Tables** → `results/phosphorus_paper/tables/`
- CSV summaries, LaTeX tables

**Reports** → `results/phosphorus_paper/reports/`
- Knitted HTML/PDF notebooks (already configured)

---

## Usage Instructions

### Rendering Individual Notebooks

```bash
# From project root
Rscript scripts/utils/render_notebook.R "scripts/phosphorus_paper/GO_Enrichment_Analysis_of_DEGs.Rmd"
```

Output will appear in: `results/phosphorus_paper/reports/GO_Enrichment_Analysis_of_DEGs.html`

### Path Setup in Rmd Files

Every Rmd should start with:

```r
---
title: "Analysis Title"
output: html_document
---

# Setup project paths
library(here)
source(here("scripts", "utils", "setup_paths.R"))
paths <- setup_project_paths("phosphorus_paper")

# Now use paths$data, paths$shared, paths$intermediate, paths$figures, etc.
```

### Available Path Variables

After sourcing `setup_paths.R`, use:

- `paths$data` - `data/phosphorus_paper/`
- `paths$shared` - `data/shared_paper/`
- `paths$intermediate` - `results/phosphorus_paper/intermediate/`
- `paths$figures` - `results/phosphorus_paper/figures/`
- `paths$tables` - `results/phosphorus_paper/tables/`
- `paths$reports` - `results/phosphorus_paper/reports/`

---

## Execution Dependencies

Based on previous I/O mapping analysis, notebooks have dependencies:

### Batch 1: Foundational (Generate Intermediates)
These create intermediate files needed by later analyses:
- `differential_lipid_analysis_leaf_treatment_interaction_model.Rmd` → Creates lipid results
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
- `scripts/00_agent_work/` (agent sandbox, git-ignored)
- Binary files (`.RDS`, `.RData`, `.csv`, `.pdf`, `.png`)

### Typical Workflow

```bash
# After refactoring Rmd files
git add scripts/phosphorus_paper/*.Rmd
git add scripts/utils/setup_paths.R
git commit -m "refactor: standardize paths in phosphorus_paper notebooks"

# Push changes
git push origin main
```

---

## Progress Tracking

### Completed ✅
- [x] Audit all hard-coded paths (172 paths identified)
- [x] Map file dependencies (180+ files classified)
- [x] Create execution roadmap (3 batches defined)
- [x] Configure .gitignore properly
- [x] Create render_notebook.R utility

### In Progress 🚧
- [ ] Create directory structure (Phase 1)
- [ ] Migrate Desktop files to data/ (Phase 1)
- [ ] Create setup_paths.R utility (Phase 1)
- [ ] Refactor phosphorus_paper Rmds (Phase 2)

### Not Started ⏳
- [ ] Test rendering all notebooks (Phase 3)
- [ ] Validate outputs (Phase 3)
- [ ] Update project README (Phase 3)
- [ ] Refactor inversion_paper scripts (Future phase)

---

## Notes for AI Assistants

### Key Principles

1. **Simplicity over complexity** - Use flat paper-level folders, not deep nesting
2. **Mirror script structure** - `scripts/phosphorus_paper/` ↔ `data/phosphorus_paper/`
3. **Preserve git history** - Don't delete files, refactor paths in place
4. **Test incrementally** - Refactor one file at a time, test immediately
5. **Focus on phosphorus_paper** - Don't touch inversion_paper scripts yet

### Where to Work

- **Agent sandbox:** `scripts/00_agent_work/` - Temporary work, git-ignored
- **Main scripts:** `scripts/phosphorus_paper/` - Refactor these in place
- **Utilities:** `scripts/utils/` - Add shared path configuration here

### What to Avoid

- ❌ Don't create semantic subdirectories (no `data/phosphorus_paper/differential_expression/`)
- ❌ Don't over-engineer with unnecessary abstraction
- ❌ Don't modify analysis logic, only paths
- ❌ Don't add comments/docstrings unless code logic is unclear
- ❌ Don't touch inversion_paper scripts (out of scope)

---

**For questions or clarification, refer to:**
- This document (CLAUDE.md)
- `scripts/00_agent_work/PHOSPHORUS_PAPER_PATH_REFACTOR_PLAN.md` (detailed plan)
- Previous audit files in `scripts/00_agent_work/` (context only, not executable)
