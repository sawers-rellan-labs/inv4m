#!/bin/bash
#BSUB -J microsynteny_6genomes
#BSUB -n 1
#BSUB -R "rusage[mem=8G] span[hosts=1]"
#BSUB -W 1:00
#BSUB -o /rsstu/users/r/rrellan/DOE_CAREER/inv4m/assembly/logs/microsynteny_6genomes_%J.out
#BSUB -e /rsstu/users/r/rrellan/DOE_CAREER/inv4m/assembly/logs/microsynteny_6genomes_%J.err

set -euo pipefail

source /usr/local/apps/miniconda20240526/etc/profile.d/conda.sh
conda activate /share/maize/frodrig4/conda/env/mcscan

PROJDIR="/rsstu/users/r/rrellan/DOE_CAREER/inv4m/assembly"
MSDIR="${PROJDIR}/microsynteny"
UPSTREAM="/rsstu/users/r/rrellan/DOE_CAREER/inv4m/microsynteny"

cd "${MSDIR}"

# ============================================================================
# Step 1: Symlink upstream pairwise blocks and BED files
# ============================================================================
echo "=== Step 1: Symlink upstream files ==="
for f in B73.PT.i1.blocks B73.mexicana.i1.blocks B73.CML457.i1.blocks B73.CML459.i1.blocks \
         PT.bed mexicana.bed CML457.bed CML459.bed; do
    if [ ! -e "${f}" ]; then
        ln -s "${UPSTREAM}/${f}" "${f}"
        echo "  Linked ${f}"
    else
        echo "  ${f} already exists"
    fi
done

# ============================================================================
# Step 2: Join all 5 pairwise block files into 6-genome blocks
# ============================================================================
echo ""
echo "=== Step 2: Join blocks (B73 + PT + TIL18 + CML457 + CML459 + Mi21) ==="
python3 -m jcvi.formats.base join \
    B73.PT.i1.blocks B73.mexicana.i1.blocks B73.CML457.i1.blocks \
    B73.CML459.i1.blocks B73.Mi21.i1.blocks \
    --noheader | cut -f1,2,4,6,8,10 > B73.6genomes.blocks

echo "Total lines: $(wc -l < B73.6genomes.blocks)"

# ============================================================================
# Step 3: Extract JMJ region (±25 flanking genes)
# ============================================================================
echo ""
echo "=== Step 3: Extract JMJ region ==="

# Use the V4 ID that was used in the 5-genome blocks
grep -n "Zm00001d051961" B73.6genomes.blocks || echo "Zm00001d051961 not found, trying Zm00001eb191790"
grep -A 25 -B 25 "Zm00001d051961\|Zm00001eb191790_T001" B73.6genomes.blocks | head -51 > blocks6

echo "blocks6 lines: $(wc -l < blocks6)"
echo ""
echo "=== blocks6 content ==="
cat blocks6

# ============================================================================
# Step 4: Highlight JMJ genes
# ============================================================================
echo ""
echo "=== Step 4: Highlight JMJ genes ==="
perl -i -pe 's/^(Zm00001eb191790_T\d+)/indigo*$1/' blocks6
perl -i -pe 's/^(Zm00001eb191820_T\d+)/indigo*$1/' blocks6
perl -i -pe 's/^(Zm00001d051961_T\d+)/indigo*$1/' blocks6

# ============================================================================
# Step 5: Create layout file
# ============================================================================
echo ""
echo "=== Step 5: Create layout file ==="
cat > blocks6.layout << 'EOF'
# x,   y, rotation, ha, va, color, ratio, label
# Row order matches blocks6 columns: B73, PT, TIL18, CML457, CML459, Mi21
# Visual order top-to-bottom: TIL18, PT, CML457, CML459, Mi21 NIL, B73
0.5, 0.25, 0, right, center, gold, 1, B73
0.5, 0.45, 0, right, center, indigo, 1, PT
0.5, 0.50, 0, right, center, indigo, 1, TIL18
0.5, 0.40, 0, right, center, indigo, 1, CML457
0.5, 0.35, 0, right, center, indigo, 1, CML459
0.5, 0.30, 0, right, center, indigo, 1, Mi21 NIL
# edges: daisy chain TIL18 -> PT -> CML457 -> CML459 -> Mi21 -> B73
e, 2, 1
e, 1, 3
e, 3, 4
e, 4, 5
e, 5, 0
EOF

echo "Layout:"
cat blocks6.layout

# ============================================================================
# Step 6: Merge BED files
# ============================================================================
echo ""
echo "=== Step 6: Merge BED files ==="
python3 -m jcvi.formats.bed merge \
    B73.bed PT.bed mexicana.bed CML457.bed CML459.bed Mi21.bed \
    -o B73_PT_mexicana_CML457_CML459_Mi21.bed

echo "Merged BED lines: $(wc -l < B73_PT_mexicana_CML457_CML459_Mi21.bed)"

# ============================================================================
# Step 7: Generate figure
# ============================================================================
echo ""
echo "=== Step 7: Generate microsynteny figure ==="
python3 -m jcvi.graphics.synteny blocks6 \
    B73_PT_mexicana_CML457_CML459_Mi21.bed blocks6.layout \
    --glyphstyle=arrow --genelabelsize=0 --notex --format svg

echo ""
echo "=== Output files ==="
ls -la blocks6.svg blocks6.pdf 2>/dev/null || echo "Figure files not found"

echo ""
echo "=== Done ==="
