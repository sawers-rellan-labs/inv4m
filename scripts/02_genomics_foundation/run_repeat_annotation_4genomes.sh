#!/bin/bash
# ===========================================================================
# Chromosomal knob repeat BLAST annotation for Figure 1 Panel A
# ===========================================================================
#
# Searches knob180 (M32524.1) and TR-1 (AY083942.1) repeat sequences against
# chromosome 4 of four Zea genomes using BLAST+ megablast.
#
# Genomes:
#   B73    - Zm-B73-REFERENCE-NAM-5.0       (lowland, standard karyotype)
#   PT     - Zm-PT-REFERENCE-HiLo-1.0       (highland, inverted karyotype)
#   TIL18  - Zx-TIL18-REFERENCE-PanAnd-1.0  (mexicana, inverted karyotype)
#   Mi21   - Mi21 NIL HiFi assembly          (highland donor, inverted karyotype)
#
# Method:
#   blastn -task megablast (word size 28, high-similarity search)
#   This matches the original searches used for Figure 1 in the manuscript.
#   See main.tex \subsection{Chromosomal knob repeat annotation} for details.
#
# Query sequences (in data/):
#   knob180_M32524.fas  - M32524.1 (Dennis & Peacock 1984)
#   TR-1_AY083942.fas   - AY083942.1 (Hsu 2003)
#
# Subject databases:
#   Chromosome 4 extracted from each genome assembly via samtools faidx.
#   Extracted chr4 FASTAs are saved as intermediate files for reproducibility.
#
# Output: results/inversion_paper/intermediate/
#   knob180_{genome}.blast  - BLAST+ outfmt 6 tabular output
#   TR-1_{genome}.blast     - BLAST+ outfmt 6 tabular output
#   {genome}_chr4.fa        - Extracted chromosome 4 sequences
#
# Dependencies: blast+ (blastn, blastdbcmd)
# Runs locally (macOS) — BLAST databases accessed via SMB mount.
# All genomes must have BLAST databases (makeblastdb -dbtype nucl) pre-built on HPC.
#
# Usage:
#   cd <project_root>   # inv4m/
#   bash scripts/02_genomics_foundation/run_repeat_annotation_4genomes.sh
#
# Date: 2026-03-07
# ===========================================================================

set -euo pipefail

# ============================================================================
# Path configuration
# ============================================================================

# Project root detection (must run from inv4m/)
if [ ! -f "CLAUDE.md" ]; then
    echo "ERROR: Run from project root (inv4m/)"
    exit 1
fi

# Input: query sequences
DATA="data"
KNOB_QUERY="${DATA}/knob180_M32524.fas"
TR1_QUERY="${DATA}/TR-1_AY083942.fas"

# Output: intermediate results
OUTDIR="results/inversion_paper/intermediate"
mkdir -p "${OUTDIR}"

# Genome FASTA locations (SMB mount)
# These are read-only reference genomes on the server
RSSTU="/Volumes/rsstu/users/r/rrellan/DOE_CAREER/inv4m"
SYNTENY_REF="${RSSTU}/synteny/ref"
MI21_DIR="${RSSTU}/nilhifimi21"

# ============================================================================
# Genome definitions
# ============================================================================

# Associative arrays: genome -> FASTA path, chr4 sequence name
declare -A GENOME_FA
GENOME_FA[B73]="${SYNTENY_REF}/B73/Zm-B73-REFERENCE-NAM-5.0.fa"
GENOME_FA[PT]="${SYNTENY_REF}/PT/Zm-PT-REFERENCE-HiLo-1.0.fa"
GENOME_FA[TIL18]="${SYNTENY_REF}/mexicana/Zx-TIL18-REFERENCE-PanAnd-1.0.fa"
GENOME_FA[Mi21]="${MI21_DIR}/ragtag/merge/ragtag.merge.fasta"

declare -A CHR4_NAME
CHR4_NAME[B73]="chr4"
CHR4_NAME[PT]="PT04"
CHR4_NAME[TIL18]="chr4"
CHR4_NAME[Mi21]="scf00000010_RagTag"

# ============================================================================
# Prerequisite checks
# ============================================================================

echo "=== Repeat annotation: 4-genome BLAST megablast ==="
echo ""

# Check tools
for tool in blastn blastdbcmd; do
    if ! command -v "$tool" &>/dev/null; then
        echo "ERROR: $tool not found in PATH"
        exit 1
    fi
done
echo "Tools: $(blastn -version 2>&1 | head -1)"

# Check query files
for f in "$KNOB_QUERY" "$TR1_QUERY"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Query file not found: $f"
        exit 1
    fi
done
echo "Queries: $(basename $KNOB_QUERY), $(basename $TR1_QUERY)"

# Check genome FASTAs
for genome in B73 PT TIL18 Mi21; do
    if [ ! -f "${GENOME_FA[$genome]}" ]; then
        echo "ERROR: Genome FASTA not found: ${GENOME_FA[$genome]}"
        echo "Is the SMB mount available at /Volumes/rsstu/...?"
        exit 1
    fi
done
echo "Genomes: B73, PT, TIL18, Mi21 — all accessible"
echo ""

# ============================================================================
# Step 1: Extract chromosome 4 from each genome
# ============================================================================

echo "=== Step 1: Extract chromosome 4 sequences ==="

for genome in B73 PT TIL18 Mi21; do
    CHR4_FA="${OUTDIR}/${genome}_chr4.fa"

    if [ -f "$CHR4_FA" ] && [ -s "$CHR4_FA" ]; then
        echo "  ${genome}: chr4 already extracted ($(wc -l < "$CHR4_FA") lines), skipping."
        continue
    fi

    echo "  ${genome}: extracting ${CHR4_NAME[$genome]} via blastdbcmd..."
    blastdbcmd -db "${GENOME_FA[$genome]}" -entry "${CHR4_NAME[$genome]}" -out "$CHR4_FA"
    echo "    → $CHR4_FA ($(wc -c < "$CHR4_FA") bytes)"
done

echo ""

# ============================================================================
# Step 2: BLAST megablast — knob180 and TR-1 vs each chr4
# ============================================================================

echo "=== Step 2: BLAST megablast searches ==="

for genome in B73 PT TIL18 Mi21; do
    CHR4_FA="${OUTDIR}/${genome}_chr4.fa"

    for query_label in knob180 TR-1; do
        if [ "$query_label" == "knob180" ]; then
            QUERY="$KNOB_QUERY"
        else
            QUERY="$TR1_QUERY"
        fi

        BLAST_OUT="${OUTDIR}/${query_label}_${genome}.blast"

        if [ -f "$BLAST_OUT" ] && [ -s "$BLAST_OUT" ]; then
            echo "  ${query_label} vs ${genome}: exists ($(wc -l < "$BLAST_OUT") hits), skipping."
            continue
        fi

        echo "  ${query_label} vs ${genome}..."
        blastn -task megablast \
            -query "$QUERY" \
            -subject "$CHR4_FA" \
            -outfmt 6 \
            > "$BLAST_OUT"
        echo "    → ${BLAST_OUT} ($(wc -l < "$BLAST_OUT") hits)"
    done
done

echo ""

# ============================================================================
# Summary
# ============================================================================

echo "=== Done ==="
echo ""
echo "BLAST results in ${OUTDIR}/:"
ls -1 "${OUTDIR}"/knob180_*.blast "${OUTDIR}"/TR-1_*.blast 2>/dev/null
echo ""
echo "Chr4 FASTAs in ${OUTDIR}/:"
ls -1 "${OUTDIR}"/*_chr4.fa 2>/dev/null
echo ""
echo "Next steps:"
echo "  1. Run breakpoint self-similarity dotplots (LAST) — see run_breakpoint_dotplots_4genomes.sh"
echo "  2. Run plot_repeat_analysis.Rmd to generate Figure 1 Panel A"
