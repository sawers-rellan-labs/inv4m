# Iso-seq test of the jmj2/jmj4 cluster annotation collapse

**Status:** plan
**Origin:** spun out of the inversion paper §JMJ Discussion. Iso-seq reviewer question (JRI017 + JRI018 + OL066) asked whether `Zm00001eb191790` in NAM v5 collapses true paralogs into one locus with alternative transcripts.

---

## Goal

Test whether the jmj2/jmj4 cluster is one locus with alternative isoforms, or multiple distinct paralogs each with its own core promoter. Use the Wang et al. 2020 (*Commun Biol* 3:78) maize Iso-seq dataset (B73 × Ki11 + reciprocal F1s).

The falsifier of the "alternative isoforms of one locus" hypothesis is **the count of distinct PacBio gene-level groups (`PB.X`) at the cluster locus**. PacBio's collapsed-transcript nomenclature is `PB.X.Y`: `X` is the gene-level group (one inferred transcription unit), `Y` is the isoform within that unit. Multiple `PB.X` groups overlapping the cluster region implies multiple transcription units, which implies multiple core promoters, which is incompatible with single-locus alternative-isoform interpretation.

This is the clean diagnostic and it does not depend on sequence-identity arguments.

## What this test can and cannot do

| Outcome at the JMJ cluster region | Inference |
|---|---|
| ≥2 distinct `PB.X` groups | Falsifies "alternative isoforms of one locus" — multiple transcription units present |
| 1 `PB.X` group with multiple `PB.X.Y` isoforms | Consistent with reviewer hypothesis from this dataset; does not confirm it (low expression / annotation-pipeline bias still possible) |
| No FL reads at the cluster | Inconclusive. Iso-seq tissues do not include leaf or SAM (see caveats). Fall back to the parsimony case (B73 v4 splits, NAM separation, tandem-repeat biology) |

## Data source

Wang B, Tseng E, Baybayan P, et al. (2020) *Commun Biol* 3:78. doi:10.1038/s42003-020-0805-8.

- Cross: B73 × Ki11 inbreds and reciprocal F1s (B73×Ki11, Ki11×B73).
- Tissues: root (14 DAG), embryo (20 DAP), endosperm (20 DAP). **No leaf, no SAM, no seedling.**
- Reference: B73 RefGen_**v4** (`Zm00001d` IDs).
- Pipeline: IsoSeq3 + cDNA_Cupcake collapse + SQANTI filter. Final: 75,118 transcripts at 23,412 loci.
- Phasing: IsoPhase, 6,907 genes with ≥40 FL reads and ≥1 SNP.
- Deposit: Zenodo 10.5281/zenodo.2611319. `F1maize.FINAL.fasta` is the collapsed transcript fasta. Expected companion artifacts (verify on download): mapped GFF/BED, per-sample FL count matrix, IsoPhase Supplementary Data 1.
- Raw: ArrayExpress E-MTAB-7837 (PacBio), E-MTAB-7394 (Illumina).

## Critical caveats — state upfront in the README of the report

1. **Tissue mismatch.** Iso-seq tissues are root + embryo + endosperm. The JMJ dosage hypothesis in the inversion paper is anchored on leaf/SAM. Positive evidence (multiple `PB.X` groups) is strong; negative evidence (no FL reads) is weak and does not falsify anything on its own.
2. **Annotation build is v4, not v5.** The collapse-into-one-locus problem is a **v5 NAM annotation** artifact. First verify whether v4 splits the 5 paralogs. If v4 splits and v5 lumps, that is publishable evidence independent of any Iso-seq work, and the Iso-seq result confirms or refines it.
3. **Ki11 is the alt parent, not Mo17.** Ki11 is a tropical NSS NAM founder. Cluster structure observed in Ki11 phased reads is a Ki11 statement; B73-origin requires explicit phasing or per-sample FL-count filtering.

## Pre-flight checks (do before writing any analysis)

1. Pull B73 RefGen_v4 annotation for the JMJ cluster region from MaizeGDB. Count distinct v4 gene models. Result drives framing of the whole test.
2. Translate the v5 ID `Zm00001eb191790` to its v4 equivalent(s) via the MaizeGDB v4↔v5 ID map. Identify the v4 gene IDs that the 5 split-paralog CDS sequences trace back to.
3. List Zenodo deposit contents. Confirm presence of: collapsed-transcript fasta, GFF/BED of mapped transcripts on v4 coordinates, per-sample FL count matrix, IsoPhase phased-allele table (Supplementary Data 1 of the paper).
4. Provenance of the 5 split-paralog query CDS sequences in `scripts/inversion_paper/jmj_5_paralog_split_expression_boxplot.Rmd` — note which v4 (or other) IDs they correspond to, since this determines what the BLAST queries actually are.

## Pipeline

1. **Verify v4 annotation.** Download v4 GFF3 for the cluster region. Tabulate gene models, exon counts, gene lengths. Compare to the v5 representation.
2. **Fetch Zenodo deposit.** Download fasta + GFF/BED + abundance + IsoPhase tables to `data/`. Write-protect (`chmod -R a-w data/`) after fetch.
3. **Spatial intersection.** From the GFF/BED of mapped transcripts on v4 coordinates, extract every `PB.X.Y` whose coordinates overlap the JMJ cluster region (use `bedtools intersect`). Count distinct `PB.X` groups. **This count is the result.**
4. **Sequence cross-check.** BLAST the 5 split-paralog CDS against `F1maize.FINAL.fasta`. For each query, list best-hit `PB.X.Y` with `pident`, `qcovhsp`, and confirm coordinate overlap with the cluster. Map paralog identity → `PB.X` group.
5. **B73-origin filter.** Two parallel paths, report both:
    - Per-sample FL count: keep transcripts with FL reads in B73 inbred samples (`B73-root`, `B73-embryo`, `B73-endosperm`).
    - IsoPhase phasing: for every cluster-overlapping transcript covered by IsoPhase, report the phased haplotype (B73 vs Ki11) directly.
6. **Report.** Brief `report.Rmd`: distinct-`PB.X` count at the cluster, paralog ↔ `PB.X` mapping table, per-sample FL count table, IsoPhase haplotype calls for any phased transcript, and the tissue/v4/Ki11 caveats restated.

## Repo layout

```
isoseq/
├── README.md          # what the test is, what it can/cannot do, how to run
├── PLAN.md            # this document
├── env.yml            # conda env: blast, bedtools, seqkit, samtools, minimap2, r-base
├── .gitignore
├── data/              # fetched, write-protected
├── scripts/
│   ├── 01_verify_v4_annotation.sh
│   ├── 02_fetch_zenodo.sh
│   ├── 03_extract_cluster_transcripts.sh
│   ├── 04_blast_paralogs.sh
│   ├── 05_join_sample_fl_counts.R
│   └── 06_report.Rmd
└── results/
    ├── intermediate/
    ├── tables/
    └── figures/
```

## "Done" looks like

A short `report.Rmd` rendering to HTML with:

- Count of v4 gene models at the JMJ cluster region.
- Count of distinct `PB.X` groups overlapping the cluster region in the Wang 2020 collapsed-transcript set.
- Per-paralog `PB.X` assignment from BLAST cross-check.
- Per-sample FL counts and IsoPhase haplotypes for cluster transcripts.
- One paragraph stating which of the three outcomes (table above) the data supports, with tissue/v4/Ki11 caveats explicit.

That output goes back into the inversion paper §JMJ as either a one-sentence supporting citation or a supplementary subsection, depending on how strong the signal is.