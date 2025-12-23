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
| [Spatial Correction](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/spatial_correction_for_INV4MXP.html) | Spatial correction for field phenotypes |
| [Differential Expression](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/differential_expression_leaf_treatment_model.html) | DEG analysis (leaf × treatment interaction) |
| [Differential Lipid Analysis](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/Lipid_differential_abundance.html) | Differential lipid abundance |
| [Growth Curves](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_growthcurves.html) | Growth curve analysis |
| [Ionome](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_ionome.html) | Mineral nutrient profiling |
| [Transcription Indices](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_make_transcription_indices.html) | Gene expression indices |
| [Phenotype Marginal Means](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_phenotype_marginal_means.html) | Phenotype marginal means |
| [GO Enrichment](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/GO_Enrichment_Analysis_of_DEGs.html) | GO term enrichment |
| [KEGG Enrichment](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/KEGG_Pathway_Enrichment_Analysis_of_DEGs.html) | KEGG pathway enrichment |
| [LION Enrichment](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/LION_Lipid_Enrichment_Analysis.html) | Lipid ontology enrichment |
| [Volcano Plots](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/volcano_plot_analysis.html) | Volcano plots for DEGs |

## Phosphorus Paper: Figure/Table Coverage

| Figure/Table | Content | Script | Status |
|--------------|---------|--------|--------|
| **Main Figures** | | | |
| Figure 1 | Phenotypes (flowering, biomass, yield) | `PSU2022_phenotype_marginal_means.Rmd` | ✅ |
| Figure 2 | Ionome (P, Ca, S, Zn) | `PSU2022_ionome.Rmd` | ✅ |
| Figure 3 | Transcriptomics & lipidomics MDS | `differential_expression_leaf_treatment_model.Rmd` + `Lipid_differential_abundance.Rmd` | ✅ |
| Figure 4 | GO & KEGG enrichment | `GO_Enrichment_Analysis_of_DEGs.Rmd` + `KEGG_Pathway_Enrichment_Analysis_of_DEGs.Rmd` | ✅ |
| Figure 5 | Senescence & transcription indices | `PSU2022_make_transcription_indices.Rmd` | ✅ |
| **Supplementary Figures** | | | |
| Figure S1 | Anthesis & plant height | `PSU2022_phenotype_marginal_means.Rmd` | ✅ |
| Figure S2 | Growth curves & parameters | `PSU2022_growthcurves.Rmd` | ✅ |
| Figure S3 | Secondary ionome (Mg, Mn, K, Fe) | `PSU2022_ionome.Rmd` | ✅ |
| Figure S4 | Euler/Upset DEG plots | `GO_Enrichment_Analysis_of_DEGs.Rmd` | ✅ |
| Figure S5 | Manhattan & volcano plots | `volcano_plot_analysis.Rmd` | ✅ |
| Figure S6 | Lipid class composition | `Lipid_differential_abundance.Rmd` | ✅ |
| Figure S7 | MS injection order | `Lipid_differential_abundance.Rmd` | ✅ |
| **Supplementary Tables** | | | |
| Table: phosphorusDEGs | Selected DEGs under -P | `differential_expression_leaf_treatment_model.Rmd` | ✅ |
| Table: leafDEGs | Selected DEGs for Leaf effect | `differential_expression_leaf_treatment_model.Rmd` | ✅ |
| Table: leafxpDEGs | Selected DEGs for Leaf×-P | `differential_expression_leaf_treatment_model.Rmd` | ✅ |
| Table: PSRupDEGs | GO:0016036 annotated DEGs | `GO_Enrichment_Analysis_of_DEGs.Rmd` | ✅ |
| Table: goleafxP_genes | Leaf×-P GO annotated | `GO_Enrichment_Analysis_of_DEGs.Rmd` | ✅ |
| Table: leaf_lipids | Differentially abundant lipids (leaf) | `Lipid_differential_abundance.Rmd` | ✅ |
| Table: phosphorus_lipids | Differentially abundant lipids (-P) | `Lipid_differential_abundance.Rmd` | ✅ |
| **Supplementary Files** | | | |
| S1 File | Senescence-associated DEGs (110 genes) | `PSU2022_make_transcription_indices.Rmd` | ✅ |
| **Infrastructure** | | | |
| Spatial correction | Pre-processing for phenotypes | `spatial_correction_for_INV4MXP.Rmd` | ✅ |
| LION enrichment | Lipid ontology analysis | `LION_Lipid_Enrichment_Analysis.Rmd` | ✅ |

## Inversion Paper: Figure/Table Coverage

*Not started - to be added*

## Quick Start

```bash
# Render a single notebook
Rscript scripts/utils/render_notebook.R scripts/phosphorus_paper/GO_Enrichment_Analysis_of_DEGs.Rmd

# Output appears in docs/phosphorus_paper/
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
