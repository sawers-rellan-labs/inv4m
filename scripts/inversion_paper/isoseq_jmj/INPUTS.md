# Inputs handoff (inv4m layout)

This subproject is now part of the inv4m repository. All annotation and query inputs come from inv4m's canonical `data/` directory. The only external fetch is the Wang 2020 Iso-seq deposit from Zenodo (the data under test), handled by `02_fetch_zenodo.sh`.

All paths below are **relative to the inv4m repo root** (`here::here()` resolves there). Run scripts from the repo root.

## 1. BLAST query fasta (5 split-paralog CDS)

**Path:** `data/jmj_5_candidates_v5_cDNA.fasta`
**Size:** 24 KB, 5 entries (write-protected; do not edit in place).

| FASTA header ID | Common name | Build | Notes |
|---|---|---|---|
| `Zm00001eb191790_T001` | jmj9 | v5 | First tandem copy |
| `Zm00001eb191790_T006` | jmj6 | v5 | Third tandem copy |
| `Zm00001eb191790_T013` | jmj2 | v5 | Fourth tandem copy |
| `Zm00001eb191820_T001` | jmj4 | v5 | Separate v5 gene model adjacent to the cluster |
| `Zm00001d051961_T002` | psi (pseudogene) | **v4** | v5 collapses this into `Zm00001eb191790_T017`; v4 transcript rescued to preserve the distinct entry |

**Provenance:** built from B73 NAM v5 cDNA, with `Zm00001eb191790`'s collapsed transcripts re-split into separate entries and the pseudogene rescued from v4. Each entry represents a distinct paralog. The Iso-seq test interrogates whether this 5-entry split is biologically valid.

## 2. v4 annotation inputs (canonical files in inv4m's data/)

The Wang 2020 Iso-seq is mapped to B73 RefGen **v4**, so all coordinate-level work uses v4. Both canonical reference files are already in `data/`; the cluster-region subsets (BED, GFF subset) are derived at runtime by `01_verify_v4_annotation.sh` and `03_extract_cluster_transcripts.sh`. No MaizeGDB / Gramene / Ensembl downloads are needed.

| File | Contents |
|---|---|
| `data/Zm-B73-REFERENCE-GRAMENE-4.0_Zm00001d.2.gff3` | Full B73 v4 GFF3 (write-protected) |
| `data/B73v4_to_B73v5.tsv` | Full v4↔v5 gene ID crossmap (write-protected) |

### Cluster region (derived from the files above)

v4 cluster span on chr4: **`chr4:175,321,383 – 175,528,400`** (~207 kb, 8 distinct v4 gene models `Zm00001d051958` – `Zm00001d051965`).

| v4 gene | start | end | strand | maps to v5 |
|---|---|---|---|---|
| `Zm00001d051958` | 175,321,383 | 175,328,916 | + | `Zm00001eb191790` |
| `Zm00001d051959` | 175,347,420 | 175,358,199 | + | `Zm00001eb191790` |
| `Zm00001d051960` | 175,362,775 | 175,366,612 | − | `Zm00001eb191790` |
| `Zm00001d051961` | 175,383,401 | 175,397,333 | + | `Zm00001eb191790` (psi) |
| `Zm00001d051962` | 175,386,555 | 175,387,938 | − | `Zm00001eb191790` |
| `Zm00001d051963` | 175,449,989 | 175,460,383 | + | `Zm00001eb191790` |
| `Zm00001d051964` | 175,484,595 | 175,495,683 | + | `Zm00001eb191790` |
| `Zm00001d051965` | 175,517,244 | 175,528,400 | + | `Zm00001eb191820` |

### v5 cluster coordinates (for reference only, used by the query fasta)

| Paralog | v5 start | v5 end |
|---|---|---|
| jmj9 (`Zm00001eb191790_T001`) | 177,405,245 | 177,414,008 |
| jmj6 (`Zm00001eb191790_T006`) | 177,505,846 | 177,516,465 |
| jmj2 (`Zm00001eb191790_T013`) | 177,542,079 | 177,552,692 |
| jmj4 (`Zm00001eb191820_T001`) | 177,574,685 | 177,584,905 |

v5 cluster region: `chr4:177,405,245 – 177,584,905`.

## 3. Wang 2020 reference inputs (bundled in this subproject)

The Wang 2020 supplementary that is small enough to commit lives next to the scripts:

| File | Contents |
|---|---|
| `scripts/inversion_paper/isoseq_jmj/refs/42003_2020_805_MOESM3_ESM.xlsx` | IsoPhase Supplementary Data 1 (phased haplotypes, 6,907 genes) |
| `scripts/inversion_paper/isoseq_jmj/refs/sample_metadata.tsv` | Barcode → (line, tissue) map, parsed from Wang 2020 Supplementary Table 1 (PDF, MOESM1). The PDF itself is not in this repo — DOI 10.1038/s42003-020-0805-8 |

## 4. Zenodo fetch (the only external download)

`02_fetch_zenodo.sh` retrieves Wang 2020 Zenodo deposit **10.5281/zenodo.2611319** and writes to a runtime directory outside `data/` (since `data/` is write-protected and gitignored as raw inputs only; Iso-seq bulk data is treated as analysis-stage). Suggested target inside the repo:

- `results/inversion_paper/isoseq_jmj/zenodo/` (gitignored — fine; regenerable)

Files retrieved:

- `F1maize.FINAL.fasta` — collapsed full-length transcripts
- `F1maize.FINAL.gff` — mapped transcripts on **v4** coordinates
- `F1maize.FINAL.demux_FL_count.txt` — per-sample FL count matrix

## 5. Result routing inside inv4m

Run scripts from the repo root. Outputs route per inv4m conventions:

| Output type | Location |
|---|---|
| Intermediate TSV / BED / txt | `results/inversion_paper/intermediate/isoseq_jmj_*` |
| Figures (PDF / PNG / SVG / RDS) | `results/inversion_paper/figures/isoseq_jmj_*` |
| LaTeX tables (if any) | `results/inversion_paper/tables/isoseq_jmj_*` |
| Rendered report HTML | `docs/inversion_paper/isoseq_jmj_report.html` |

## 6. Symbol caveat (do not collapse the two "jmj2" meanings)

In the originating analysis there are two distinct uses of "jmj2":

- **In this subproject**, "jmj2" means **only `Zm00001eb191790_T013`** — a single paralog.
- In the upstream gene-level analysis, "jmj2" was sometimes used as a shorthand for the v5 composite `Zm00001eb191790`, which conflates jmj9 + psi + jmj6 + jmj2.

When reporting results, always use the full transcript ID alongside the common name.

## 7. Notes for re-running

The scripts (`01_*` through `06_*`) were originally written against a standalone project layout with `data/queries/` subset files. After the merge into inv4m, the subset BEDs and GFF subset are no longer pre-bundled; `01_verify_v4_annotation.sh` and `03_extract_cluster_transcripts.sh` derive them from `data/Zm-B73-REFERENCE-GRAMENE-4.0_Zm00001d.2.gff3` and `data/B73v4_to_B73v5.tsv`. If a script still hardcodes a `data/queries/...` path, update it to read from inv4m's canonical paths above or write the subset to `results/inversion_paper/intermediate/isoseq_jmj_*` at runtime.