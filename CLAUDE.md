# inv4m Project Guide

**Last Updated:** 2025-12-23
**Status:** Phosphorus Paper - Complete ✅ | Inversion Paper - Complete ✅
**Version:** v1.1.0

---

## Project Overview

The **inv4m** project analyzes the maize chromosomal inversion Inv4m and its effects on phosphorus stress response. The codebase contains R/Rmarkdown analysis scripts for two papers:

1. **Inversion Paper** - Characterizes Inv4m effects across field environments ✅
2. **Phosphorus Paper** - Analyzes phosphorus stress response and Inv4m interactions ✅

### Repository Structure

```
inv4m/
├── scripts/
│   ├── 00_agent_work/           # AI agent sandbox (git-ignored)
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

## Inversion Paper - Complete ✅

### Scripts (7 Rmd files in `scripts/inversion_paper/`)

| File | Purpose | Status |
|------|---------|--------|
| `plot_genotype_get_correlated_loci.Rmd` | SNP distribution and correlation | ✅ |
| `Corrected_phenotype_analysis_PSU2022.Rmd` | Corrected phenotype analysis | ✅ |
| `differential_expression_leaf_treatment_model.Rmd` | DEG analysis | ✅ |
| `Analyze_MaizeNetome_TransRegulation.Rmd` | Trans coexpression network | ✅ |
| `get_WGCNA_modules.Rmd` | WGCNA network analysis | ✅ |
| `GO_Enrichment_Trans_Network.Rmd` | Network GO analysis | ✅ |
| `Crow2020_reanalysis.Rmd` | Crow 2020 reanalysis | ✅ |

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

### Data Directory (Symlink)

`data/` is a symbolic link to `../inv4mRNA/data` (shared across projects).
- Flat structure with ~40 files at root level
- Read-only - do not create subdirectories

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

Note: HTML reports are routed to `docs/{paper}/` via the `knit:` field in YAML headers.

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

### Inversion Paper ✅ Complete
- [x] Read `docs/inversion_paper/main.tex` and extract figures/tables
- [x] Create `scripts/inversion_paper/` directory structure
- [x] Recover needed scripts from git history (`b2dd1488`)
- [x] Map figures/tables to scripts (coverage checklist)
- [x] Copy differential expression script for independent refinement
- [x] Update all paths to use `setup_paths.R`
- [x] Test rendering all notebooks
- [x] Add coverage table to README.md
- [x] Move `Annotation_assembly.Rmd` to phosphorus paper (now handles GO/KEGG/LION enrichment panels for phosphorus paper)

---

## Notes for AI Assistants

### Key Conventions

1. **Output routing:**
   - CSV files → `paths$intermediate`
   - LaTeX tables → `paths$tables`
   - Figures → `paths$figures`
   - HTML reports → `docs/{paper}/` (via YAML `knit:` field or render_notebook.R)

2. **Path management:** All scripts use `setup_paths.R` utility with `here::here()`

3. **Agent sandbox:** `scripts/00_agent_work/` - Temporary work, git-ignored

### What to Avoid

- ❌ Don't put CSV files in `tables/` (LaTeX only)
- ❌ Don't create subdirectories in `data/` (it's a symlink)
- ❌ Don't modify analysis logic without explicit request
