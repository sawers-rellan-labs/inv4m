# isoseq_jmj

Test of the jmj2/jmj4 cluster annotation collapse using the Wang et al. 2020
maize Iso-seq dataset (B73 x Ki11 + reciprocal F1s).

See `PLAN.md` for the goal, the falsifier, data sources, caveats, and pipeline.

## Setup

```
conda env create -f env.yml
conda activate isoseq_jmj
```

## Workflow

Scripts are numbered. Run in order; each is short enough to read before running.

1. `scripts/01_verify_v4_annotation.sh` - pull B73 v4 GFF3 for the cluster region; count v4 gene models. Drives the framing of the whole test.
2. `scripts/02_fetch_zenodo.sh` - fetch Wang 2020 Zenodo deposit (DOI 10.5281/zenodo.2611319). Write-protect `data/` after.
3. `scripts/03_extract_cluster_transcripts.sh` - intersect mapped-transcript GFF/BED with the cluster region. **Count distinct `PB.X` groups - this is the result.**
4. `scripts/04_blast_paralogs.sh` - BLAST the 5 split-paralog CDS queries against `F1maize.FINAL.fasta`; map paralog -> `PB.X`.
5. `scripts/05_join_sample_fl_counts.R` - join per-sample FL counts and IsoPhase haplotypes to cluster transcripts.
6. `scripts/06_report.Rmd` - render report.

## Caveats

Tissues are root / embryo / endosperm. No leaf, no SAM. Negative results do not
falsify the dosage hypothesis. Reference build is v4, not v5. Ki11 (not Mo17)
is the alt parent.
