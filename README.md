<div align="center">
  <img src="docs/Inv4m_cover.png" alt="Inv4m Cover" width="400"/>
</div>

# inv4m

Analysis pipeline for the maize chromosomal inversion Inv4m: **modulation of flowering time, plant height, and growth regulation gene networks**. Manuscript text complete; Phase 6 figure / table additions complete (PA2024 hybrid panel ✅ 2026-05-14; ZEAL NIL supp figure ✅ 2026-05-15; **gene-name / description revision pass across all body + supplement tables, trans-network figures re-rendered, Section 3.5 citations wired ✅ 2026-05-21**). **Next priorities:** Rubén's full feedback and coauthor suggestions; Discussion integration of ZEAL multi-donor replication + PA2024 hybrid yield framing; JMJ paralog and teosinte single-copy supplementary figures; Overleaf PNG re-upload (`Figure_2_phenotypes.png`, `inv4mZEAL.png`, `Figure_4_C_trans_network.png`, `supp_novel_trans_network_full.png`); bibtex audit of new citations (`zhang2015b`, `gan2014`, `song2018`) + carry-over (`bates2015`, `kuznetsova2017`, `fransz2016`, `desmarais2017`, `minow2021`); copyedit. See `agent/inversion_paper/HANDOVER_inversion_paper_revision.md` for the active task list.

**[View Analysis Reports](https://sawers-rellan-labs.github.io/inv4m/)**

## Overview

This repository contains R/Rmarkdown analysis notebooks for studying the Inv4m inversion in maize (*Zea mays*), focusing on:

- Phenotypic effects on flowering time and plant height
- Gene-by-environment interactions across field environments
- Differential gene expression and candidate gene identification (JMJ cluster)
- WGCNA network perturbation analysis
- Phosphorus stress response (companion paper)
- GO/KEGG pathway enrichment

## Phosphorus Paper: Figure/Table Coverage

| Figure/Table | Content | Notebook | Status |
|--------------|---------|----------|--------|
| **Main Figures** | | | |
| Figure 1 | Phenotypes (flowering, biomass, yield) | [`PSU2022_phenotype_marginal_means.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_phenotype_marginal_means.html) | ✅ |
| Figure 2 | Ionome of P, Zn, Ca, S — 4 panels: concentration (A), grain/stover ratio (B), content per plant (C), harvest index (D) | [`PSU2022_ionome.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_ionome.html) + [`PSU2022_ionome_content.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_ionome_content.html) | ✅ |
| Figure 3 | Transcriptomics & lipidomics MDS | [`differential_expression_leaf_treatment_model.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/differential_expression_leaf_treatment_model.html) + [`Lipid_differential_abundance.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/Lipid_differential_abundance.html) | ✅ |
| Figure 4 | GO & KEGG enrichment | [`Annotation_assembly.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/Annotation_assembly.html) | ✅ |
| Figure 5 | Senescence & transcription indices | [`PSU2022_make_transcription_indices.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_make_transcription_indices.html) | ✅ |
| **Supplementary Figures** | | | |
| Figure S1 | Marginal effects of phosphorus deficiency on plant height and kernel traits (PH, KW50, TKN, TKW) | [`PSU2022_phenotype_marginal_means.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_phenotype_marginal_means.html) | ✅ |
| Figure S2 | Inv4m differences in anthesis and plant height | [`PSU2022_phenotype_marginal_means.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_phenotype_marginal_means.html) | ✅ |
| Figure S3 | Stover dry weight growth curves and derived logistic parameters | [`PSU2022_growthcurves.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_growthcurves.html) | ✅ |
| Figure S4 | Ionome of Mg, Mn, K, Fe — 4 panels parallel to Figure 2 (concentration, ratio, content, HI) | [`PSU2022_ionome.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_ionome.html) + [`PSU2022_ionome_content.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_ionome_content.html) | ✅ |
| Figure S5 | Inv4m effects on the ionome pooled across phosphorus treatments (Mg, Ca, Zn, Fe, K; 4 metric families) | [`PSU2022_ionome_content.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/PSU2022_ionome_content.html) | ✅ |
| Figure S6 | Euler diagrams and UpSet plot of strong DEG sets (with GO BP annotation coverage) | [`GO_Enrichment_Analysis_of_DEGs.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/GO_Enrichment_Analysis_of_DEGs.html) | ✅ |
| Figure S7 | Manhattan plots and volcano plot for DEGs and DALs | [`volcano_plot_analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/volcano_plot_analysis.html) | ✅ |
| Figure S8 | Lipid class composition and treatment and leaf stage effects | [`Lipid_differential_abundance.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/Lipid_differential_abundance.html) | ✅ |
| Figure S9 | Mass spectrometry injection order effects on lipid profiles | [`Lipid_differential_abundance.Rmd`](https://sawers-rellan-labs.github.io/inv4m/phosphorus_paper/Lipid_differential_abundance.html) | ✅ |
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

## Inversion Paper: Revision Status

### Gene-name / description revision pass (2026-05-21)

Comprehensive naming consistency pass across body and supplement tables; trans-network supplementary figures re-rendered. Master list at `data/locus_labels_master.csv` is the single source of truth (write-locked).

| Change | Old | New | Source |
|---|---|---|---|
| Rename `roc4-1` | `roc4-1` (mis-curated as cyclophilin paralog) | `borr` | MaizeGDB Pfam Borealin (PF10512); Arabidopsis ortholog AT4G39630 BORR; chromosomal passenger complex kinetochore component |
| Simplify `roc4-2` | `roc4-2` | `roc4` | Now the only cyclophilin in the DEG set; Pfam Pro\_isomerase (PF00160) |
| Fix typo `dwy1` | `dwy1` | `dyw1` | MaizeGDB Pfam DYW\_deaminase (PF14432) |
| `smo4` description | "SUMO E1 uba-2 like" (wrong) | "Ribosome biogenesis protein NOP53" | MaizeGDB; Arabidopsis SMO4 / NOP53 homolog (`zhang2015b`) |
| `prd4` description | "Phosphatidylinositol N-acetyglucosaminlytransferase" (wrong) | "Protein PAIR1 (putative recombination initiation defect4)" | MaizeGDB |
| `zfrvt` description | (blank) | "Non-LTR retroelement reverse transcriptase (zf-RVT)" | MaizeGDB UniProt Q8W233 + Pfam zf-RVT |
| `engd2` description | (blank / "GTPase-like") | "OBG-type G domain-containing protein" | MaizeGDB; Obg/YchF superfamily (Suwastika 2008/2014); Arabidopsis ortholog AT1G56050 ENGD-2 |
| `Zm00001eb194180` | "troponin T, skeletal muscle-like" (animal sarcomere, biologically implausible) | (blank) | dropped from master CSV |
| `Zm00001eb126770` | `cl59140_1` (clone marker) | (blank label) | marker pattern; module-DEG notebooks patched to skip marker symbols via `is_marker` flag |

Plus: filled `desc_pannzer` fallbacks for `hpse3`, `cdi`, `o3l1`, `ppp`, `gst`. Citations added in Section 3.5 trans-network prose: `zhang2015b` (SMO4), `gan2014` (Arabidopsis JMJ flowering), `song2018` (rice OsJMJ703). Suwastika 2008/2014 (Obg/YchF family) recorded in handover but not yet inserted in body.

Supplement structural updates: new `tab:DEGs_distro` + `tab::gxe` tables; trans-network table split by region and sorted by FDR; "Locus" column header → "**Label**" (convention recorded in `scripts/utils/consolidate_locus_labels.R`: editorial shorthand, not naming orthodoxy); `---` placeholders removed from empty cells; `+` sign added to positive log2FC; all Gene IDs italicized. LD-linked gene filter (FDR < 0.005 with the Inv4m tagging SNP) extended from network construction to FT/PH candidate selection — removes `ychf` and `tip4c` from Table 2.

Figures re-rendered with updated labels (sandbox disabled for webshot/PhantomJS): `Figure_4_C_trans_network.png` (Fig.~4 panel C, jmj4 neighborhood) and `supp_novel_trans_network_full.png` (Fig.~S11, full novel MST).

### Peer review edits applied (2026-02-24)

18 text edits addressing internal peer review (archived to `agent/_trash/inversion_paper/peer_review_inversion_paper.md` and `agent/_trash/inversion_paper/review_response_edits.md` after the 2026-05-07 audit pass):

| Category | Key changes |
|----------|------------|
| **Attribution** | Soften Inv4m → "Inv4m introgression"; note reduction from Crow 2020 linkage drag (57→24 Mb); reframe OR=1.02 as evidence against position effects |
| **GxE context** | Lead with environment-dependent framing; qualify PSU2022 effects as site-specific; reframe internode data within GxE reversal |
| **JMJ cluster** | Lead Discussion with CNV (5:1 copy number) as baseline; foreground field-specific regulatory suppression (49-61% of expected) as novel finding; clarify single-copy state is ancestral |
| **Mechanistic claims** | "Mechanistic chain" → "working model"; soften SAM-to-field causal language; note ChIP-seq/H3K4me3 needed |
| **WGCNA** | Add caveat about DEG input set; cite magenta (non-significant) as counterexample |
| **Trans-network** | "Novel" → "Dataset-specific" throughout; explain low MaizeNetome overlap as tissue/context difference |
| **Local adaptation** | "Characteristic of" → "consistent with"; add reciprocal transplant caveat |
| **Limitations** | Expand to 4 structured points: flanking drag, B73 background, sample size, SAM/RNA-seq stage gap |
| **Minor** | Fix units nm⁻¹ → μm⁻¹; clarify CML457/CML459 as CIMMYT tropical lines |

## Inversion Paper: Figure/Table Coverage

| Figure/Table | Content | Notebook | Status |
|--------------|---------|----------|--------|
| **Main Figures** | | | |
| Figure 1 | Inv4m delimitation: breeding scheme (A), repeat annotation (B), AnchorWave dotplots (C), breakpoint self-similarity (D), genotype map (E–F) | [`plot_Figure_1.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_Figure_1.html) (assembly) + [`plot_synteny_and_repeats.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_synteny_and_repeats.html) (B–D) + [`plot_genotype_get_correlated_loci.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_genotype_get_correlated_loci.html) (E–F) | ✅ |
| Figure 2 | Effect of Inv4m on PH/DTA/DTS (PA2022 NIL, A); PH/TGW/TGN (PA2024 hybrid, B); SAM micrograph (C) + Height/h/r/h/r² (NIL Seedling SAMs, D) | [`plot_Figure_2.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_Figure_2.html) (assembly) + [`Corrected_phenotype_analysis_PSU2022.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/Corrected_phenotype_analysis_PSU2022.html) + [`Corrected_phenotype_analysis_PSU2024.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/Corrected_phenotype_analysis_PSU2024.html) + [`SAM_morphology_analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/SAM_morphology_analysis.html) | ✅ |
| Figure 3 | Global and local transcriptomic effects (8 panels, incl. volcano panel C) | [`assemble_figure3_RNAseq.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/assemble_figure3_RNAseq.html) + [`volcano_plot_analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/volcano_plot_analysis.html) (panel C) + manhattan/MDS panel scripts | ✅ |
| Figure 5 | Trans coexpression network of Inv4m DEGs | [`Analyze_MaizeNetome_TransRegulation_network_split.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/Analyze_MaizeNetome_TransRegulation_network_split.html) | ✅ |
| Figure 6 | WGCNA module perturbation | [`assemble_WGCNA_figure.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/assemble_WGCNA_figure.html) + field_perturbation | ✅ |
| Figure 7 | JMJ cluster expression + 6-genome microsynteny (incl. Mi21 NIL) | [`jmj_cluster_expression_boxplot.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/jmj_cluster_expression_boxplot.html) + `blocks6` (from RSSTU Mi21 microsynteny) | 🔶 update figure |
| Figure 8 | B73 phenotypic/gene expression model | Manual/Illustrator | N/A |
| **Supplementary Figures** | | | |
| Figure S1 | SNP distribution and correlation | [`plot_genotype_get_correlated_loci.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_genotype_get_correlated_loci.html) | ✅ |
| Figure S2 | ZEAL NIL panel Inv4m effect on flowering (DTA, DTS) and plant height (4 panels: lineage corrected boxplots + forest) | [`Zeal_Inv4m_flowering_lmm.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/Zeal_Inv4m_flowering_lmm.html) | ✅ |
| Figure S3 | GxE interaction plots (MI21 donor) | [`inv4mGxE_3_env.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/inv4mGxE_3_env.html) | ✅ |
| Figure S4 | GxE effect sizes forest plot | [`inv4mGxE_3_env.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/inv4mGxE_3_env.html) | ✅ |
| Figure S5 | Internode analysis (4 panels: height, photos, schematic, profiles) | [`internode_analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/internode_analysis.html) + photos | ✅ |
| Figure S6 | WGCNA module bootstrap support (Genotype Response × Leaf Gradient) | [`WGCNA_module_perturbation_test.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/WGCNA_module_perturbation_test.html) | ✅ |
| Figure S7 | WGCNA module GO enrichment | `field_perturbation/07_module_annotation.Rmd` | ✅ |
| **Main Tables** | | | |
| Table 1 | Inv4m breakpoints | [`plot_genotype_get_correlated_loci.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_genotype_get_correlated_loci.html) | ✅ |
| Table 2 | FT/PH gene candidates | [`phenotype_association_filter.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/phenotype_association_filter.html) | ✅ |
| **Supplementary Tables** | | | |
| Table S1 | Inv4m breakpoints (4 genomes incl. Mi21 NIL) | [`make_breakpoint_tables.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/make_breakpoint_tables.html) | ✅ |
| Table S2 | Breakpoint knob repeats (4 genomes incl. Mi21 NIL) | [`make_breakpoint_tables.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/make_breakpoint_tables.html) | ✅ |
| Table S3 | Effect of conditions on gene expression | [`differential_expression_leaf_treatment_model.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/differential_expression_leaf_treatment_model.html) | ✅ |
| Table S4 | GxE interaction statistics (3 environments) | [`inv4mGxE_3_env.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/inv4mGxE_3_env.html) | ✅ |
| Table S5 | Module preservation statistics | `field_perturbation/06_preservation.Rmd` | ✅ |
| Table S6 | Greenyellow module DEGs (sec6/pcna2 growth network) | [`greenyellow_module_characterization.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/greenyellow_module_characterization.html) | ✅ |
| Table S7 | Pink module DEGs (jmj2/jmj4 co-expression) | [`jmj_pink_module_characterization.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/jmj_pink_module_characterization.html) | ✅ |
| **Supporting Scripts** | | | |
| Figure 1 assembly | Panel A (SVG) + B–D + E–F composition | [`plot_Figure_1.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_Figure_1.html) | ✅ |
| Figure 1 panels B–D | Repeat annotation, AnchorWave dotplots, breakpoint self-similarity | [`plot_synteny_and_repeats.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_synteny_and_repeats.html) + [`fig1_panel_helpers.R`](scripts/inversion_paper/fig1_panel_helpers.R) | ✅ |
| Figure 2 assembly | A/B/C/D 2×2 cowplot at 12×7 in @ 300 dpi (Rubén's spec) | [`plot_Figure_2.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/plot_Figure_2.html) | ✅ |
| PA2024 hybrid phenotypes | NIL-derived hybrid focal contrast (Inv4_Mi21 vs Inv4_B73); 41 NIL_xxxx as random-effect cohort | [`Corrected_phenotype_analysis_PSU2024.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/Corrected_phenotype_analysis_PSU2024.html) | ✅ |
| PA2024 field layout | 2×2 P_SQUARE inference + X/Y derivation (RPubs-shared) | [`PSU2024_field_layout.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/PSU2024_field_layout.html) | ✅ |
| SAM estimation stats | Bootstrap 95% BCa CIs via dabestr (Ho et al. 2019) — alternative to NHST | [`SAM_dabestr_estimation.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/SAM_dabestr_estimation.html) | ✅ |
| Field perturbation pipeline | WGCNA consensus + preservation | `scripts/inversion_paper/field_perturbation/` (7 scripts) | ✅ |
| WGCNA figure assembly | Figure 6 composition | [`assemble_WGCNA_figure.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/assemble_WGCNA_figure.html) | ✅ |
| GO enrichment (network) | Network GO analysis | [`GO_Enrichment_Trans_Network.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/GO_Enrichment_Trans_Network.html) | ✅ |
| Crow 2020 reanalysis | Reference dataset reanalysis | [`Crow2020_reanalysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/Crow2020_reanalysis.html) | ✅ |
| 6-genome microsynteny | JMJ cluster panel B (jcvi pipeline, incl. Mi21 NIL) | `scripts/02_genomics_foundation/blocks6` + `blocks6.layout` + `prepare_Mi21_for_mcscan.sh` + `run_ortholog_B73_Mi21.sh` + `merge_blocks_and_plot.sh` | 🔶 update figure |
| Breakpoint tables | Table S1 (delimitation) + S2 (knob repeats) data | [`make_breakpoint_tables.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/make_breakpoint_tables.html) | ✅ |
| Manhattan plots | Fig 3 panels D, E, G, H | [`make_manhattan_plots.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/make_manhattan_plots.html) | ✅ |
| Volcano plot | Figure 3 panel C | [`volcano_plot_analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/volcano_plot_analysis.html) | ✅ |
| SAM morphology | DIC microscopy analysis | [`SAM_morphology_analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/SAM_morphology_analysis.html) | ✅ |
| JMJ paralog expression | Transcript-level DEG with corrected cDNA ref | [`jmj_5_paralog_split_expression_boxplot.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/jmj_5_paralog_split_expression_boxplot.html) | ✅ |
| Greenyellow module | Greenyellow module characterization (sec6/pcna2) | [`greenyellow_module_characterization.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/greenyellow_module_characterization.html) | ✅ |
| JMJ pink module | Pink module characterization (jmj2/jmj4 growth network) | [`jmj_pink_module_characterization.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/jmj_pink_module_characterization.html) | ✅ |
| Phenotype association filter | FT/PH candidate gene overlap with DEGs | [`phenotype_association_filter.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/phenotype_association_filter.html) | ✅ |
| GxE analysis | 3-environment genotype-by-environment interaction | [`inv4mGxE_3_env.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/inv4mGxE_3_env.html) | ✅ |
| Internode analysis | NC2025 internode length profiles | [`internode_analysis.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/internode_analysis.html) | ✅ |
| PA2025 phenotypes | Spatial correction for PA2025 (formerly PSU2025) | [`Corrected_phenotype_analysis_PSU2025.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/Corrected_phenotype_analysis_PSU2025.html) | ✅ |
| NC2025 phenotypes | Spatial correction for NC2025 (formerly CLY2025) | [`Corrected_phenotype_analysis_CLY2025_modified.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/Corrected_phenotype_analysis_CLY2025_modified.html) | ✅ |
| Sequence divergence vs DE | Mi21–B73 CDS divergence vs Inv4m DEG (Supp divergence figure) | [`sequence_divergence_vs_DE.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/sequence_divergence_vs_DE.html) | ✅ |
| R² sliding window | Inv4m / flanking / outside region comparison (intermediate for divergence figure) | [`compare_r2_sliding_window_regions.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/compare_r2_sliding_window_regions.html) | ✅ |
| GDD lookup | Growing degree day pre-correction (intermediate for spatial-correction Rmds) | [`gdd_pre_spatial_correction.Rmd`](https://sawers-rellan-labs.github.io/inv4m/inversion_paper/gdd_pre_spatial_correction.html) | ✅ |

**Status Legend:** ✅ Ready | 🔶 In Progress | ⚠️ Needs work | ❌ Missing

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

## Quick Start

```bash
# Render a single notebook
Rscript scripts/utils/render_notebook.R scripts/phosphorus_paper/GO_Enrichment_Analysis_of_DEGs.Rmd

# Output appears in docs/phosphorus_paper/
```

## Repository Structure

```
inv4m/
├── agent/                   # AI agent sandbox (git-ignored, ephemeral scratch)
├── scripts/
│   ├── phosphorus_paper/    # Paper 2 analysis notebooks (14 Rmd files) ✅
│   ├── inversion_paper/     # Paper 1 analysis notebooks (27 Rmd files + field_perturbation/) ✅
│   └── utils/               # Shared utilities (setup_paths.R, render_notebook.R)
├── data/                    # Input data (in-tree real folder, write-protected, not tracked)
├── docs/                    # Published HTML reports (GitHub Pages)
│   ├── phosphorus_paper/    # Paper 2 reports
│   └── inversion_paper/     # Paper 1 reports + main.tex
└── results/                 # Generated outputs (not tracked)
    ├── phosphorus_paper/
    └── inversion_paper/
```

## Requirements

- R >= 4.0
- Key packages: `tidyverse`, `here`, `limma`, `edgeR`, `clusterProfiler`, `ggplot2`, `kableExtra`

## DEG/DAL terminology

Differentially expressed genes and differentially abundant lipids are classified in two tiers:

1. **Significant** — `FDR < 0.05` (column `is_DEG` / `is_DL`)
2. **Strong** — `FDR < 0.05` AND `|log2FC|` passes a predictor-specific threshold (column `is_strong_DEG` / `is_strong_DL`)
   - `-P` and `Inv4m` main effects: `|log2FC| > 1.5`
   - `Leaf` main effect and all interactions (`Leaf:-P`, `Inv4m:-P`, `Leaf:Inv4m`): `|log2FC| > 0.5`

"Strong" names the effect-size filter honestly; FDR already carries the statistical claim. Earlier versions of this pipeline used the term "high-confidence" for the same tier — the rename to "strong" was applied across manuscript and scripts on 2026-04-24 to match the inversion paper's terminology. Any remaining `hiconf` reference in intermediate CSV files on disk is pre-refactor data not regenerated by the current pipeline; rendering any current notebook writes `is_strong_*` columns.

## Data

Input data files live in `data/` — a write-protected, in-tree real folder (was a symlink to `../inv4mRNA/data` until 2026-05; consolidated). The pipeline reads from this flat directory and writes outputs to organized subdirectories in `results/`. To add new inputs: `chmod -R u+w data/` → drop files → `chmod -R a-w data/` to re-lock.

## License

[Add license information]

## Citation

[Add citation when published]
