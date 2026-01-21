<div align="center">
  <img src="docs/Inv4m_cover.png" alt="Inv4m Cover" width="400"/>
</div>

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

## Phosphorus Paper: Figure/Table Coverage

| Figure/Table | Content | Notebook | Status |
|--------------|---------|----------|--------|
| **Main Figures** | | | |
| Figure 1 | Phenotypes (flowering, biomass, yield) | [`PSU2022_phenotype_marginal_means.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_phenotype_marginal_means.html) | ✅ |
| Figure 2 | Ionome (P, Ca, S, Zn) | [`PSU2022_ionome.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_ionome.html) | ✅ |
| Figure 3 | Transcriptomics & lipidomics MDS | [`differential_expression_leaf_treatment_model.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/differential_expression_leaf_treatment_model.html) + [`Lipid_differential_abundance.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/Lipid_differential_abundance.html) | ✅ |
| Figure 4 | GO & KEGG enrichment | [`Annotation_assembly.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/Annotation_assembly.html) | ✅ |
| Figure 5 | Senescence & transcription indices | [`PSU2022_make_transcription_indices.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_make_transcription_indices.html) | ✅ |
| **Supplementary Figures** | | | |
| Figure S1 | Anthesis & plant height | [`PSU2022_phenotype_marginal_means.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_phenotype_marginal_means.html) | ✅ |
| Figure S2 | Growth curves & parameters | [`PSU2022_growthcurves.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_growthcurves.html) | ✅ |
| Figure S3 | Secondary ionome (Mg, Mn, K, Fe) | [`PSU2022_ionome.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_ionome.html) | ✅ |
| Figure S4 | Euler/Upset DEG plots | [`GO_Enrichment_Analysis_of_DEGs.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/GO_Enrichment_Analysis_of_DEGs.html) | ✅ |
| Figure S5 | Manhattan & volcano plots | [`volcano_plot_analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/volcano_plot_analysis.html) | ✅ |
| Figure S6 | Lipid class composition | [`Lipid_differential_abundance.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/Lipid_differential_abundance.html) | ✅ |
| Figure S7 | MS injection order | [`Lipid_differential_abundance.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/Lipid_differential_abundance.html) | ✅ |
| **Supplementary Tables** | | | |
| Table: phosphorusDEGs | Selected DEGs under -P | [`differential_expression_leaf_treatment_model.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/differential_expression_leaf_treatment_model.html) | ✅ |
| Table: leafDEGs | Selected DEGs for Leaf effect | [`differential_expression_leaf_treatment_model.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/differential_expression_leaf_treatment_model.html) | ✅ |
| Table: leafxpDEGs | Selected DEGs for Leaf×-P | [`differential_expression_leaf_treatment_model.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/differential_expression_leaf_treatment_model.html) | ✅ |
| Table: PSRupDEGs | GO:0016036 annotated DEGs | [`GO_Enrichment_Analysis_of_DEGs.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/GO_Enrichment_Analysis_of_DEGs.html) | ✅ |
| Table: goleafxP_genes | Leaf×-P GO annotated | [`GO_Enrichment_Analysis_of_DEGs.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/GO_Enrichment_Analysis_of_DEGs.html) | ✅ |
| Table: leaf_lipids | Differentially abundant lipids (leaf) | [`Lipid_differential_abundance.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/Lipid_differential_abundance.html) | ✅ |
| Table: phosphorus_lipids | Differentially abundant lipids (-P) | [`Lipid_differential_abundance.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/Lipid_differential_abundance.html) | ✅ |
| **Supplementary Files** | | | |
| S1 File | Senescence-associated DEGs (110 genes) | [`PSU2022_make_transcription_indices.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_make_transcription_indices.html) | ✅ |
| **Infrastructure** | | | |
| Spatial correction | Pre-processing for phenotypes | [`spatial_correction_for_INV4MXP.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/spatial_correction_for_INV4MXP.html) | ✅ |
| LION enrichment | Lipid ontology analysis | [`LION_Lipid_Enrichment_Analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/LION_Lipid_Enrichment_Analysis.html) | ✅ |
| Annotation assembly | GO/KEGG/LION enrichment panels | [`Annotation_assembly.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/Annotation_assembly.html) | ✅ |

## Inversion Paper: Figure/Table Coverage

| Figure/Table | Content | Notebook | Status |
|--------------|---------|----------|--------|
| **Main Figures** | | | |
| Figure 1 | Inv4m delimitation, breakpoints, breeding design | [`plot_genotype_get_correlated_loci.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_genotype_get_correlated_loci.html) | ✅ |
| Figure 2 | Effect of Inv4m on PH, DTA, DTS, HI | [`Corrected_phenotype_analysis_PSU2022.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/Corrected_phenotype_analysis_PSU2022.html) | ✅ |
| Figure 3 | Global and local transcriptomic effects (8 panels) | [`assemble_figure3_RNAseq.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/assemble_figure3_RNAseq.html) + panel scripts | ⚠️ |
| Figure 4 | Volcano plots for DEGs | [`volcano_plot_analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/volcano_plot_analysis.html) | ⚠️ |
| Figure 5 | Trans coexpression network of Inv4m DEGs | [`Analyze_MaizeNetome_TransRegulation.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/Analyze_MaizeNetome_TransRegulation.html) | ✅ |
| Figure 6 | WGCNA module perturbation | [`assemble_WGCNA_figure.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/assemble_WGCNA_figure.html) + field_perturbation | ✅ |
| Figure (jmj) | JMJ cluster expression + microsynteny | [`make_jmj_expression_boxplot.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/make_jmj_expression_boxplot.html) + Manual | ✅ |
| Figure (cellprolif) | PCNA2 + SMO4 expression (supplementary) | [`make_jmj_expression_boxplot.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/make_jmj_expression_boxplot.html) | ✅ |
| Figure 7 | B73 phenotypic/gene expression model | Manual/Illustrator | N/A |
| **New Analyses** | | | |
| Figure (internode) | Internode length profiles | [`internode_analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/internode_analysis.html) | ✅ |
| Figure (jmj-tx) | JMJ2 transcript-level expression | `jmj_transcript_analysis.Rmd` (planned) | ⬜ Blocked |
| Figure S-GxE | GxE interaction plots (3 environments) | [`inv4mGxE_3_env.Rmd`](https://sawers-rellan-labs.github.io/inv4m/shared_paper/inv4mGxE_3_env.html) | ✅ |
| **Main Tables** | | | |
| Table 1 | Inv4m breakpoints | [`plot_genotype_get_correlated_loci.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_genotype_get_correlated_loci.html) | ✅ |
| Table 2 | FT/PH gene candidates | [`differential_expression_leaf_treatment_model.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/differential_expression_leaf_treatment_model.html) | ✅ |
| **Supplementary Figures** | | | |
| Figure S1 | SNP distribution and correlation | [`plot_genotype_get_correlated_loci.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_genotype_get_correlated_loci.html) | ✅ |
| **Supplementary Tables** | | | |
| Table S1 | Inv4m breakpoints and knob repeats | [`plot_genotype_get_correlated_loci.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_genotype_get_correlated_loci.html) | ✅ |
| Table S2 | Effect of conditions on gene expression | [`differential_expression_leaf_treatment_model.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/differential_expression_leaf_treatment_model.html) | ✅ |
| Table S-GxE | GxE interaction statistics (3 environments) | [`inv4mGxE_3_env.Rmd`](https://sawers-rellan-labs.github.io/inv4m/shared_paper/inv4mGxE_3_env.html) | ✅ |
| **Supporting Scripts** | | | |
| Field perturbation pipeline | WGCNA consensus + preservation | `scripts/inversion_paper/field_perturbation/` (7 scripts) | ✅ |
| WGCNA figure assembly | Figure 6 composition | [`assemble_WGCNA_figure.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/assemble_WGCNA_figure.html) | ✅ |
| WGCNA modules (legacy) | Co-expression network analysis | [`get_WGCNA_modules.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/get_WGCNA_modules.html) | ✅ |
| GO enrichment (network) | Network GO analysis | [`GO_Enrichment_Trans_Network.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/GO_Enrichment_Trans_Network.html) | ✅ |
| Crow 2020 reanalysis | Reference dataset reanalysis | [`Crow2020_reanalysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/Crow2020_reanalysis.html) | ✅ |
| Manhattan plots | Fig 3 panels D, E, G, H | [`make_manhattan_plots.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/make_manhattan_plots.html) | ✅ |
| Volcano plot | Fig 3 panel C / Fig 4 | [`volcano_plot_analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/volcano_plot_analysis.html) | ⚠️ |
| Figure 3 assembly | 8-panel composite figure | [`assemble_figure3_RNAseq.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/assemble_figure3_RNAseq.html) | ⚠️ |
| SAM morphology | DIC microscopy analysis | [`SAM_morphology_analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/SAM_morphology_analysis.html) | ✅ |

**Status Legend:** ✅ Ready | ⚠️ Needs work | ❌ Missing

---

## Gene Label Consolidation Method

Short-hand gene labels (e.g., `jmj4`, `pip1d`, `acsn1`) were consolidated for figure annotation using a hierarchical approach:

### Label Sources (Priority Order)

1. **Curated labels** (28 genes) - Manual curation from phosphorus paper (`selected_DEGs_curated_locus_label_2.csv`)
2. **MaizeGDB symbols** (94 genes) - Official locus symbols from `gene_symbol.tab`, filtered to exclude uninformative markers
3. **LLM-proposed labels** (269 genes) - Generated from PANNZER functional descriptions using consistent naming conventions

### Marker Pattern Filtering

MaizeGDB symbols include genetic markers that are uninformative for figure labels. These were identified by analyzing the consensus map (`data/maizegdb_consensus_map/`) and filtered using regex:

```r
MARKER_PATTERN <- paste0(
  "^(umc|pco|bnlg|pza|gpm|csu|php|IDP|TIDP)[0-9]+",  # SSR/SNP markers
  "|^cl[0-9]+_",                                       # Clone markers
  "|^si[0-9]{5,}",                                     # Sequence identifiers
  "|^LOC[0-9]+",                                       # NCBI locus tags
  "|^AY[0-9]+",                                        # GenBank accessions
  "|^Zm00001[de]?b?[0-9]+",                            # Assembly gene IDs
  "|^GRMZM"                                            # B73 RefGen_v3 IDs
)
```

Key insight: Markers have `locus_symbol` but NO `locus_name`; real genes have both.

### LLM-Proposed Label Conventions

For genes with PANNZER descriptions but no symbol, short labels (≤7 characters) were generated following these conventions:

| Category | Convention | Example |
|----------|------------|---------|
| Domain-based | Domain abbreviation + number | `ppr3` (PPR domain), `ring1` (RING finger) |
| Function-based | Function abbreviation | `tars` (threonyl-tRNA synthetase) |
| Protein family | Family name lowercase | `dnaj1` (DnaJ chaperone) |
| Existing nomenclature | Match Arabidopsis/rice orthologs | `abh1`, `gata12` |

### Final Coverage

| Source | Count | % |
|--------|-------|---|
| curated | 28 | 6% |
| symbol | 94 | 20% |
| llm_proposed | 269 | 58% |
| **Total labeled** | **391** | **84%** |
| Unlabeled (no annotation) | 74 | 16% |

Hub gene coverage: 55/65 (85%)

### Scripts

- `scripts/utils/consolidate_locus_labels.R` - Main consolidation workflow
- `scripts/utils/merge_proposed_labels.R` - Merge LLM-proposed labels into master

### Data Files

- `data/locus_labels_master.csv` - Master label file (391 genes)
- `data/locus_labels_proposed_top50.csv` - First 50 LLM-proposed with rationale
- `data/locus_labels_proposed_remaining.csv` - Remaining 219 LLM-proposed

---

## Recent Updates

**2026-01-21:** GxE analysis pipeline complete:
- ✅ **GxE analysis** - Full 3-environment analysis (PSU2022, PSU2025, CLY2025)
  - Refactored spatial correction scripts with path standardization
  - GDD integration from NASA POWER temperature data
  - 10 output CSVs + 3 supplementary figures (interaction plots, forest plot, temperature reaction norms)
  - HTML report: `docs/shared_paper/inv4mGxE_3_env.html`

**2026-01-20:** New analyses implementation:
- ✅ **Internode measurements** - Complete! Created `internode_analysis.Rmd` with 4 figures + 4 CSVs
  - Internode length profiles by position from top
  - Node count comparison by genotype
  - Height validation (sum of internodes vs direct measurement)
  - Dissection validation
- ⬜ **JMJ transcript-level DEG** - Waiting for kallisto re-run on HPC
- See: `scripts/00_agent_work/missing_analysis_plan_20260120.md`

**2026-01-20:** Results writing and supplementary figures:
- ✅ Drafted trans-network results section (136 genes, 552 edges, jmj4 neighborhood)
- ✅ Drafted WGCNA perturbation results (jmj2/jmj4 hub connectivity collapse: 98-99%)
- ✅ Added PCNA2 + SMO4 cell proliferation expression boxplot (supplementary figure)
- ✅ Created `SAM_morphology_analysis.Rmd` - DIC microscopy SAM measurements
- ✅ Fixed undefined LaTeX references (fig::volcano → fig:transcriptome)
- ✅ Gene annotation correction: Zm00001eb192850 uba2 → smo4 (NOP53 ortholog)

**2026-01-06:** WGCNA Figure 6 implementation complete:
- ✅ Created `assemble_WGCNA_figure.Rmd` - 3-panel composition (A: dendrogram, B: boxplot, C: hub scatter)
- ✅ Added GO term annotations to delta kWithin boxplot (rrvgo-reduced, y=0.5)
- ✅ Boxplots colored by module with `scale_fill_identity()`
- ✅ Added WGCNA consensus methods to main.tex (Shahan et al. 2018 citation)
- ✅ Figure output: `WGCNA_module_perturbation.pdf/png` (12x12 inch, heights 0.5:1:1)

**2026-01-05:** Gene label consolidation for WGCNA hub gene plots:
- ✅ Created `consolidate_locus_labels.R` - Hierarchical label consolidation
- ✅ Filtered MaizeGDB markers (umc, pco, bnlg, pza, gpm, etc.) using consensus map analysis
- ✅ Generated 269 LLM-proposed labels from PANNZER descriptions
- ✅ Final coverage: 391/465 genes (84%), hub genes 55/65 (85%)
- ✅ Hub connectivity plot updated with base_size=25, ggrepel labels size=5

**2026-01-05:** JMJ cluster figure with expression boxplot:
- ✅ Created `make_jmj_expression_boxplot.Rmd` - jmj2/jmj4 expression across tissues
- ✅ Figure shows consistent downregulation in Inv4m across PSU2022 and Crow2020
- ✅ Ionome-style boxplots with gold (B73) and purple (Inv4m) color scheme
- ✅ Caption updated in main.tex with 3 panels (A: expression, B: microsynteny, C: transcripts)

**2026-01-04:** WGCNA module perturbation figure planning:
- ✅ Created handover document for WGCNA figure implementation
- ✅ Figure 6: Boxplot colors by module, GO annotations, hub connectivity
- ✅ Assembly notebook `assemble_WGCNA_figure.Rmd` created (see 2026-01-06)
- ✅ Pipeline data: `results/inversion_paper/field_perturbation/run_20251231_201332/`

**2026-01-02:** Figure 3 panel generation infrastructure for inversion paper revision:
- ✅ Created `assemble_figure3_RNAseq.Rmd` - Assembly notebook for 8-panel composite figure
- ✅ Created `volcano_plot_analysis.Rmd` - Dedicated volcano plot script (Panel C)
- ✅ Updated `make_manhattan_plots.Rmd` - Dynamic DEG counts in titles (Panels D, E, G, H)
- ✅ Updated `differential_expression_leaf_treatment_model.Rmd` - MDS saved as RDS (Panel B)
- ✅ Panel infrastructure: RDS for ggplot panels (B, C), PNG for raster panels (A, D-H)
- ⚠️ Panel F (haplotype) needs ggsave update in genotype script
- ⚠️ Figure composition needs final refinement

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
│   ├── inversion_paper/     # Paper 1 analysis notebooks (12 Rmd files) ✅
│   └── utils/               # Shared utilities (setup_paths.R, render_notebook.R)
├── data/                    # Input data (symlink, not tracked)
├── docs/                    # Published HTML reports (GitHub Pages)
│   ├── phosphorus_paper/    # Paper 2 reports (12 HTML files)
│   └── inversion_paper/     # Paper 1 reports
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
