#!/bin/bash
# ===========================================================================
# Breakpoint self-similarity dotplots (LAST) for Figure 1 Panel B
# ===========================================================================
#
# Generates self-vs-self dotplots at Inv4m breakpoint segments for four Zea
# genomes using LAST (Large-scale Alignment Search Tool).
#
# Genomes:
#   B73    - Zm-B73-REFERENCE-NAM-5.0       (lowland, standard karyotype)
#   PT     - Zm-PT-REFERENCE-HiLo-1.0       (highland, inverted karyotype)
#   TIL18  - Zx-TIL18-REFERENCE-PanAnd-1.0  (mexicana, inverted karyotype)
#   Mi21   - Mi21 NIL HiFi assembly          (highland donor, inverted karyotype)
#
# Method:
#   1. Extract breakpoint segments via blastdbcmd
#   2. Build LAST database (lastdb)
#   3. Self-align (lastal -f TAB)
#   4. Plot dotplot (last-dotplot -x 200 -y 200)
#
# Output: results/inversion_paper/intermediate/
#   {genome}_brkpt_{up,down}.fasta  - Extracted breakpoint segments
#   {genome}_brkpt_{up,down}.last   - LAST tabular alignment
#   {genome}_brkpt_{up,down}.png    - Self-similarity dotplot
#
# Dependencies: blast+ (blastdbcmd), last (lastdb, lastal, last-dotplot)
# Runs locally (macOS) — genomes accessed via SMB mount.
#
# Usage:
#   cd <project_root>   # inv4m/
#   bash scripts/02_genomics_foundation/run_breakpoint_dotplots_4genomes.sh
#
# Date: 2026-03-08
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

# Output directory
OUTDIR="results/inversion_paper/intermediate"
mkdir -p "${OUTDIR}"

# Genome FASTA locations (SMB mount)
RSSTU="/Volumes/rrellan/DOE_CAREER/inv4m"
SYNTENY_REF="${RSSTU}/synteny/ref"
MI21_DIR="${RSSTU}/nilhifimi21"

# LAST binary path (built from source if not in PATH)
LAST_BIN="${LAST_BIN:-${HOME}/bio/bin}"

# ============================================================================
# Genome definitions
# ============================================================================

# Associative arrays: genome -> FASTA path, chr4 name
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

# Breakpoint coordinates: genome -> "start-end" for upstream and downstream
declare -A BRKPT_UP
BRKPT_UP[B73]="172561959-172882309"
BRKPT_UP[PT]="173369064-173486186"
BRKPT_UP[TIL18]="180269950-180365316"
BRKPT_UP[Mi21]="167621035-167839092"

declare -A BRKPT_DOWN
BRKPT_DOWN[B73]="188131461-188220418"
BRKPT_DOWN[PT]="186925483-187092654"
BRKPT_DOWN[TIL18]="193570651-193734606"
BRKPT_DOWN[Mi21]="156519809-156752504"

# ============================================================================
# Prerequisite checks
# ============================================================================

echo "=== Breakpoint self-similarity dotplots (LAST) ==="
echo ""

# Check blastdbcmd
if ! command -v blastdbcmd &>/dev/null; then
    echo "ERROR: blastdbcmd not found in PATH"
    exit 1
fi

# Check LAST tools (try PATH first, then LAST_BIN)
LASTDB=""
LASTAL=""
LAST_DOTPLOT=""

if command -v lastdb &>/dev/null; then
    LASTDB="lastdb"
    LASTAL="lastal"
    LAST_DOTPLOT="last-dotplot"
elif [ -x "${LAST_BIN}/lastdb" ]; then
    LASTDB="${LAST_BIN}/lastdb"
    LASTAL="${LAST_BIN}/lastal"
    LAST_DOTPLOT="${LAST_BIN}/last-dotplot"
else
    echo "ERROR: LAST tools not found in PATH or ${LAST_BIN}"
    echo "Install via: git clone https://gitlab.com/mcfrith/last.git && cd last && make"
    exit 1
fi

echo "Tools: blastdbcmd $(blastdbcmd -version 2>&1 | head -1)"
echo "        $($LASTDB --version 2>&1 | head -1)"
echo ""

# Check genome FASTAs (SMB mount)
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
# Generate dotplots
# ============================================================================

for genome in B73 PT TIL18 Mi21; do
    for direction in up down; do
        PREFIX="${genome}_brkpt_${direction}"
        FASTA="${OUTDIR}/${PREFIX}.fasta"
        LAST_OUT="${OUTDIR}/${PREFIX}.last"
        PNG="${OUTDIR}/${PREFIX}.png"

        # Get coordinates
        if [ "$direction" == "up" ]; then
            RANGE="${BRKPT_UP[$genome]}"
        else
            RANGE="${BRKPT_DOWN[$genome]}"
        fi

        echo "--- ${genome} ${direction}stream breakpoint (${CHR4_NAME[$genome]}:${RANGE}) ---"

        # Skip if final PNG already exists
        if [ -f "$PNG" ] && [ -s "$PNG" ]; then
            echo "  Dotplot exists, skipping."
            echo ""
            continue
        fi

        # Step 1: Extract segment
        if [ ! -f "$FASTA" ] || [ ! -s "$FASTA" ]; then
            echo "  Extracting segment..."
            blastdbcmd -db "${GENOME_FA[$genome]}" \
                -entry "${CHR4_NAME[$genome]}" \
                -range "${RANGE}" \
                -out "$FASTA"
            echo "    → $FASTA ($(wc -c < "$FASTA") bytes)"
        else
            echo "  FASTA exists, reusing."
        fi

        # Step 2: Build LAST database
        if [ ! -f "${OUTDIR}/${PREFIX}.prj" ]; then
            echo "  Building LAST database..."
            $LASTDB "${OUTDIR}/${PREFIX}" "$FASTA"
        else
            echo "  LAST database exists, reusing."
        fi

        # Step 3: Self-align
        if [ ! -f "$LAST_OUT" ] || [ ! -s "$LAST_OUT" ]; then
            echo "  Running self-alignment..."
            $LASTAL -f TAB "${OUTDIR}/${PREFIX}" "$FASTA" > "$LAST_OUT"
            echo "    → $LAST_OUT ($(wc -l < "$LAST_OUT") lines)"
        else
            echo "  Alignment exists, reusing."
        fi

        # Step 4: Generate dotplot (fontsize=1 hides axis labels for clean assembly)
        echo "  Generating dotplot..."
        $LAST_DOTPLOT --fontsize=1 --border-pixels=0 --margin-color=white -x 200 -y 200 "$LAST_OUT" "$PNG"
        echo "    → $PNG"
        echo ""
    done
done

# ============================================================================
# Summary
# ============================================================================

echo "=== Done ==="
echo ""
echo "Dotplot PNGs in ${OUTDIR}/:"
ls -lh "${OUTDIR}"/*_brkpt_*.png 2>/dev/null || echo "  (none found)"
echo ""
echo "Next steps:"
echo "  1. Inspect dotplots for self-similarity patterns at breakpoints"
echo "  2. Assemble into Figure 1 Panel B"
