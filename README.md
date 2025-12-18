# inv4m

Analysis pipeline for the maize chromosomal inversion Inv4m and its effects on phosphorus stress response.

**[View Analysis Reports](https://sawers-rellan-labs.github.io/inv4m/)**

## Overview

This repository contains R/Rmarkdown analysis notebooks for studying the Inv4m inversion in maize (*Zea mays*), focusing on:

- Differential gene expression under phosphorus stress
- Lipid metabolism and membrane remodeling
- Ionome profiling
- Growth and phenotype analysis
- GO/KEGG pathway enrichment

## Analysis Notebooks

| Notebook | Description |
|----------|-------------|
| [Spatial Correction](https://sawers-rellan-labs.github.io/inv4m/spatial_correction_for_INV4MXP.html) | Spatial correction for field phenotypes |
| [Differential Expression](https://sawers-rellan-labs.github.io/inv4m/differential_expression_leaf_treatment_model.html) | DEG analysis (leaf × treatment interaction) |
| Differential Lipid Analysis | Differential lipid abundance *(report pending)* |
| [Growth Curves](https://sawers-rellan-labs.github.io/inv4m/PSU2022_growthcurves.html) | Growth curve analysis |
| [Ionome](https://sawers-rellan-labs.github.io/inv4m/PSU2022_ionome.html) | Mineral nutrient profiling |
| [Transcription Indices](https://sawers-rellan-labs.github.io/inv4m/PSU2022_make_transcription_indices.html) | Gene expression indices |
| [Phenotype Marginal Means](https://sawers-rellan-labs.github.io/inv4m/PSU2022_phenotype_marginal_means.html) | Phenotype marginal means |
| [GO Enrichment](https://sawers-rellan-labs.github.io/inv4m/GO_Enrichment_Analysis_of_DEGs.html) | GO term enrichment |
| [KEGG Enrichment](https://sawers-rellan-labs.github.io/inv4m/KEGG_Pathway_Enrichment_Analysis_of_DEGs.html) | KEGG pathway enrichment |
| [LION Enrichment](https://sawers-rellan-labs.github.io/inv4m/LION_Lipid_Enrichment_Analysis.html) | Lipid ontology enrichment |
| [Volcano Plots](https://sawers-rellan-labs.github.io/inv4m/volcano_plot_analysis.html) | Volcano plots for DEGs |

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
│   └── utils/               # Shared utilities
├── data/                    # Input data (symlink, not tracked)
├── docs/                    # Published HTML reports (GitHub Pages)
└── results/                 # Generated outputs (not tracked)
```

## Requirements

- R >= 4.0
- Key packages: `tidyverse`, `here`, `limma`, `edgeR`, `clusterProfiler`, `ggplot2`

## Data

Input data files should be placed in `data/` (symlinked to shared data directory). The pipeline reads from this flat directory structure and writes outputs to organized subdirectories in `results/`.

## License

[Add license information]

## Citation

[Add citation when published]
