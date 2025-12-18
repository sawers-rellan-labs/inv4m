# inv4m

Analysis pipeline for the maize chromosomal inversion Inv4m and its effects on phosphorus stress response.

## Overview

This repository contains R/Rmarkdown analysis notebooks for studying the Inv4m inversion in maize (*Zea mays*), focusing on:

- Differential gene expression under phosphorus stress
- Lipid metabolism and membrane remodeling
- Ionome profiling
- Growth and phenotype analysis
- GO/KEGG pathway enrichment

## Quick Start

```bash
# Render a single notebook
Rscript scripts/utils/render_notebook.R scripts/phosphorus_paper/GO_Enrichment_Analysis_of_DEGs.Rmd

# Output appears in results/phosphorus_paper/reports/
```

## Repository Structure

```
inv4m/
├── scripts/
│   ├── phosphorus_paper/    # Analysis notebooks (11 Rmd files)
│   └── utils/               # Shared utilities (setup_paths.R, render_notebook.R)
├── data/                    # Input data (symlink, not tracked)
└── results/                 # Generated outputs (not tracked)
    └── phosphorus_paper/
        ├── intermediate/    # Processed CSV/RDS files
        ├── figures/         # Publication figures
        ├── tables/          # LaTeX tables
        └── reports/         # Rendered HTML notebooks
```

## Analysis Notebooks

| Notebook | Description |
|----------|-------------|
| `spatial_correction_for_INV4MXP.Rmd` | Spatial correction for field phenotypes |
| `differential_expression_leaf_treatment_model.Rmd` | DEG analysis (leaf x treatment interaction) |
| `differential_lipid_analysis_leaf_treatment_interaction_model.Rmd` | Differential lipid abundance |
| `PSU2022_growthcurves.Rmd` | Growth curve analysis |
| `PSU2022_ionome.Rmd` | Mineral nutrient profiling |
| `PSU2022_make_transcription_indices.Rmd` | Gene expression indices |
| `PSU2022_phenotype_marginal_means.Rmd` | Phenotype marginal means |
| `GO_Enrichment_Analysis_of_DEGs.Rmd` | GO term enrichment |
| `KEGG_Pathway_Enrichment_Analysis_of_DEGs.Rmd` | KEGG pathway enrichment |
| `LION_Lipid_Enrichment_Analysis.Rmd` | Lipid ontology enrichment |
| `volcano_plot_analysis.Rmd` | Volcano plots for DEGs |

## Requirements

- R >= 4.0
- Key packages: `tidyverse`, `here`, `limma`, `edgeR`, `clusterProfiler`, `ggplot2`

## Data

Input data files should be placed in `data/` (symlinked to shared data directory). The pipeline reads from this flat directory structure and writes outputs to organized subdirectories in `results/`.

## License

[Add license information]

## Citation

[Add citation when published]
