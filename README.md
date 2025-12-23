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

| Figure/Table | Content | Script | Status |
|--------------|---------|--------|--------|
| **Main Figures** | | | |
| Figure 1 | Inv4m delimitation, breakpoints, breeding design | `Annotation_assembly.Rmd` + `plot_genotype_get_correlated_loci.Rmd` | ✅ |
| Figure 2 | Effect of Inv4m on PH, DTA, DTS, HI | `Corrected_phenotype_analysis_PSU2022.Rmd` | ✅ |
| Figure 3 | Global and local transcriptomic effects | `differential_expression_leaf_treatment_model.Rmd` | ✅ |
| Figure 4 | Volcano plots for DEGs | `differential_expression_leaf_treatment_model.Rmd` | ✅ |
| Figure 5 | Trans coexpression network of Inv4m DEGs | `Analyze_MaizeNetome_TransRegulation.Rmd` | ✅ |
| Figure 6 | B73 phenotypic/gene expression model | Manual/Illustrator | N/A |
| **Main Tables** | | | |
| Table 1 | Inv4m breakpoints | `Annotation_assembly.Rmd` | ✅ |
| Table 2 | FT/PH gene candidates | `differential_expression_leaf_treatment_model.Rmd` | ✅ |
| **Supplementary Figures** | | | |
| Figure S1 | SNP distribution and correlation | `plot_genotype_get_correlated_loci.Rmd` | ✅ |
| **Supplementary Tables** | | | |
| Table S1 | Inv4m breakpoints and knob repeats | `Annotation_assembly.Rmd` | ✅ |
| Table S2 | Effect of conditions on gene expression | `differential_expression_leaf_treatment_model.Rmd` | ✅ |
| **Supporting Scripts** | | | |
| WGCNA modules | Co-expression network analysis | `get_WGCNA_modules.Rmd` | ✅ |
| GO enrichment (network) | Network GO analysis | `GO_Enrichment_Trans_Network.Rmd` | ✅ |
| Crow 2020 reanalysis | Reference dataset reanalysis | `Crow2020_reanalysis.Rmd` | ✅ |

**Status Legend:** ✅ Ready | ⚠️ Needs work | ❌ Missing

---

## Recent Updates

**2025-12-23:** All inversion paper analysis scripts (8/8) are now fully operational and path-standardized:
- ✅ Fixed `Crow2020_reanalysis.Rmd` - Removed hard-coded server paths
- ✅ Standardized all output paths to use `paths$intermediate`
- ✅ Removed vestigial directory creation code
- ✅ All scripts render successfully with outputs in correct locations
- ✅ 100% conformance to project directory structure

**2025-12-22:** Completed phosphorus paper analysis pipeline:
- ✅ All 12 scripts path-standardized and rendering successfully
- ✅ Complete figure/table coverage mapped and verified
- ✅ Infrastructure utilities (`setup_paths.R`, `render_notebook.R`) in place

---

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
│   ├── phosphorus_paper/    # Paper 2 analysis notebooks (12 Rmd files) ✅
│   ├── inversion_paper/     # Paper 1 analysis notebooks (8 Rmd files) ✅
│   └── utils/               # Shared utilities (setup_paths.R, render_notebook.R)
├── data/                    # Input data (symlink, not tracked)
├── docs/                    # Published HTML reports (GitHub Pages)
│   ├── phosphorus_paper/    # Paper 2 reports (12 HTML files)
│   └── inversion_paper/     # Paper 1 reports (8 HTML files)
└── results/                 # Generated outputs (not tracked)
    ├── phosphorus_paper/
    └── inversion_paper/
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
