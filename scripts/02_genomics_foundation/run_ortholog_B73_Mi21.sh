#!/bin/bash
#BSUB -J ortholog_B73_Mi21
#BSUB -n 8
#BSUB -R "rusage[mem=32G] span[hosts=1]"
#BSUB -W 4:00
#BSUB -o /rsstu/users/r/rrellan/DOE_CAREER/inv4m/assembly/logs/ortholog_B73_Mi21_%J.out
#BSUB -e /rsstu/users/r/rrellan/DOE_CAREER/inv4m/assembly/logs/ortholog_B73_Mi21_%J.err

set -euo pipefail

source /usr/local/apps/miniconda20240526/etc/profile.d/conda.sh
conda activate /share/maize/frodrig4/conda/env/mcscan

PROJDIR="/rsstu/users/r/rrellan/DOE_CAREER/inv4m/assembly"
MSDIR="${PROJDIR}/microsynteny"
UPSTREAM="/rsstu/users/r/rrellan/DOE_CAREER/inv4m/microsynteny"

cd "${MSDIR}"

# ============================================================================
# Step 1: Symlink B73 reference BED/CDS from upstream microsynteny dir
# ============================================================================
echo "=== Step 1: Symlink B73 reference files ==="
for f in B73.bed B73.cds; do
    if [ ! -e "${f}" ]; then
        ln -s "${UPSTREAM}/${f}" "${f}"
        echo "  Linked ${f}"
    else
        echo "  ${f} already exists"
    fi
done

# ============================================================================
# Step 1b: Prefix Mi21 gene IDs to avoid collision with B73 IDs
#   Liftoff reuses B73 gene names (Zm00001eb*) — jcvi needs unique IDs
# ============================================================================
echo "=== Step 1b: Prefix Mi21 gene IDs with Mi21_ ==="
if [ ! -e "Mi21_prefixed.bed" ]; then
    sed 's/\(Zm00001eb[0-9]*_T[0-9]*\)/Mi21_\1/g' Mi21.bed > Mi21_prefixed.bed
    mv Mi21_prefixed.bed Mi21.bed
    sed 's/>\(Zm00001eb[0-9]*_T[0-9]*\)/>Mi21_\1/' Mi21.cds > Mi21_prefixed.cds
    mv Mi21_prefixed.cds Mi21.cds
    echo "  Prefixed Mi21 BED and CDS"
fi

echo "B73.bed lines: $(wc -l < B73.bed)"
echo "B73.cds seqs:  $(grep -c '^>' B73.cds)"
echo "Mi21.bed lines: $(wc -l < Mi21.bed)"
echo "Mi21.cds seqs:  $(grep -c '^>' Mi21.cds)"
echo "Sample Mi21.bed:"
head -3 Mi21.bed

# ============================================================================
# Step 2: Clean previous run artifacts
# ============================================================================
echo ""
echo "=== Step 2: Clean previous run artifacts ==="
rm -f B73.Mi21.anchors B73.Mi21.anchors.new B73.Mi21.anchors.simple \
      B73.Mi21.last B73.Mi21.last.filtered B73.Mi21.lifted.anchors \
      B73.Mi21.i1.blocks B73.Mi21.pdf

# ============================================================================
# Step 3: Pairwise ortholog detection (LAST alignment + synteny anchors)
# ============================================================================
echo ""
echo "=== Step 3: B73 vs Mi21 ortholog detection ==="
python3 -m jcvi.compara.catalog ortholog B73 Mi21 --cscore=.99 --no_strip_names

# ============================================================================
# Step 4: Screen synteny anchors
# ============================================================================
echo ""
echo "=== Step 4: Screen synteny anchors ==="
python3 -m jcvi.compara.synteny screen --minspan=30 --simple \
    B73.Mi21.anchors B73.Mi21.anchors.new

# ============================================================================
# Step 5: Generate mcscan blocks
# ============================================================================
echo ""
echo "=== Step 5: Generate mcscan blocks ==="
python3 -m jcvi.compara.synteny mcscan B73.bed B73.Mi21.lifted.anchors \
    --iter=1 -o B73.Mi21.i1.blocks

echo ""
echo "=== Block file summary ==="
echo "Lines: $(wc -l < B73.Mi21.i1.blocks)"
echo "JMJ region in blocks:"
grep -E "Zm00001eb191790|Zm00001eb191820|Mi21_Zm00001eb191790|Mi21_Zm00001eb191820" B73.Mi21.i1.blocks || echo "  JMJ genes not found in blocks"

echo ""
echo "=== Done ==="
ls -la B73.Mi21.*
