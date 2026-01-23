#!/bin/bash
# Run 5-genome microsynteny analysis for JMJ cluster figure
# Genomes: B73, PT, TIL18 (mexicana), CML457, CML459
#
# Prerequisites:
#   - jcvi installed: pip install jcvi
#   - CML457 and CML459 GFF3 + CDS files in new_genomes/
#
# Can run locally - jcvi microsynteny is not computationally intensive

set -e

# Activate conda environment (HPC)
CONDA_ENV="/share/maize/frodrig4/conda/env/mcscan"
if [ -d "$CONDA_ENV" ]; then
    source $(conda info --base)/etc/profile.d/conda.sh
    conda activate "$CONDA_ENV"
    echo "Using conda env: ${CONDA_ENV}"
else
    echo "ERROR: conda env not found at ${CONDA_ENV}"
    exit 1
fi

# Set working directory (adjust for local vs HPC)
# HPC path:
WORKDIR="/rsstu/users/r/rrellan/DOE_CAREER/inv4m/microsynteny"
# Local mounted path (uncomment if running locally):
# WORKDIR="/Volumes/DOE_CAREER/inv4m/microsynteny"
DATADIR="${WORKDIR}/new_genomes"

# JMJ cluster query gene (for extracting blocks)
JMJ_QUERY="Zm00001eb191790"  # jmj2 in B73 V5
JMJ_QUERY_ALT="Zm00001d051961"  # Alternative V4 ID used in some blocks

# Number of flanking genes to include in microsynteny plot
FLANK=25

echo "=== 5-Genome Microsynteny Analysis for JMJ Cluster ==="
cd "${WORKDIR}"

# ============================================================================
# STEP 1: Format new genome annotations
# ============================================================================
echo ""
echo "=== Step 1: Format CML457 and CML459 annotations ==="

# Check for CML457 files (adjust filenames after download)
CML457_GFF=$(ls ${DATADIR}/Zm-CML457*.gff3 2>/dev/null | head -1)
CML457_CDS=$(ls ${DATADIR}/Zm-CML457*.cds.fa 2>/dev/null | head -1)

if [ -z "$CML457_GFF" ] || [ -z "$CML457_CDS" ]; then
    echo "WARNING: CML457 files not found in ${DATADIR}/"
    echo "Expected: Zm-CML457-REFERENCE-*.gff3 and *.cds.fa"
    echo "Skipping CML457..."
    HAS_CML457=false
else
    echo "Found CML457: $(basename $CML457_GFF)"
    python3 -m jcvi.formats.gff bed --type=mRNA --key=ID --primary_only "$CML457_GFF" -o CML457.bed
    python3 -m jcvi.formats.fasta format "$CML457_CDS" CML457.cds
    HAS_CML457=true
fi

# Check for CML459 files
CML459_GFF=$(ls ${DATADIR}/Zm-CML459*.gff3 2>/dev/null | head -1)
CML459_CDS=$(ls ${DATADIR}/Zm-CML459*.cds.fa 2>/dev/null | head -1)

if [ -z "$CML459_GFF" ] || [ -z "$CML459_CDS" ]; then
    echo "WARNING: CML459 files not found in ${DATADIR}/"
    echo "Expected: Zm-CML459-REFERENCE-*.gff3 and *.cds.fa"
    echo "Skipping CML459..."
    HAS_CML459=false
else
    echo "Found CML459: $(basename $CML459_GFF)"
    python3 -m jcvi.formats.gff bed --type=mRNA --key=ID --primary_only "$CML459_GFF" -o CML459.bed
    python3 -m jcvi.formats.fasta format "$CML459_CDS" CML459.cds
    HAS_CML459=true
fi

# ============================================================================
# STEP 2: Pairwise ortholog detection
# ============================================================================
echo ""
echo "=== Step 2: Pairwise ortholog detection ==="

if [ "$HAS_CML457" = true ]; then
    echo "Running B73 vs CML457..."
    python3 -m jcvi.compara.catalog ortholog B73 CML457 --cscore=.99 --no_strip_names
    python3 -m jcvi.compara.synteny screen --minspan=30 --simple B73.CML457.anchors B73.CML457.anchors.new
    python3 -m jcvi.compara.synteny mcscan B73.bed B73.CML457.lifted.anchors --iter=1 -o B73.CML457.i1.blocks
fi

if [ "$HAS_CML459" = true ]; then
    echo "Running B73 vs CML459..."
    python3 -m jcvi.compara.catalog ortholog B73 CML459 --cscore=.99 --no_strip_names
    python3 -m jcvi.compara.synteny screen --minspan=30 --simple B73.CML459.anchors B73.CML459.anchors.new
    python3 -m jcvi.compara.synteny mcscan B73.bed B73.CML459.lifted.anchors --iter=1 -o B73.CML459.i1.blocks
fi

# ============================================================================
# STEP 3: Merge blocks
# ============================================================================
echo ""
echo "=== Step 3: Merge blocks files ==="

# Start with existing B73.PT.mexicana blocks
# Then add CML columns

if [ "$HAS_CML457" = true ] && [ "$HAS_CML459" = true ]; then
    # 5 genomes: B73, PT, TIL18, CML457, CML459
    python3 -m jcvi.formats.base join B73.PT.i1.blocks B73.mexicana.i1.blocks B73.CML457.i1.blocks B73.CML459.i1.blocks \
        --noheader | cut -f1,2,4,6,8,10 > B73.5genomes.blocks

    grep -A ${FLANK} -B ${FLANK} "${JMJ_QUERY_ALT}" B73.5genomes.blocks > blocks5

    echo "Created blocks5 with 5 genomes"

elif [ "$HAS_CML457" = true ]; then
    # 4 genomes: B73, PT, TIL18, CML457
    python3 -m jcvi.formats.base join B73.PT.i1.blocks B73.mexicana.i1.blocks B73.CML457.i1.blocks \
        --noheader | cut -f1,2,4,6,8 > B73.4genomes.blocks

    grep -A ${FLANK} -B ${FLANK} "${JMJ_QUERY_ALT}" B73.4genomes.blocks > blocks4

    echo "Created blocks4 with 4 genomes (missing CML459)"

elif [ "$HAS_CML459" = true ]; then
    # 4 genomes: B73, PT, TIL18, CML459
    python3 -m jcvi.formats.base join B73.PT.i1.blocks B73.mexicana.i1.blocks B73.CML459.i1.blocks \
        --noheader | cut -f1,2,4,6,8 > B73.4genomes.blocks

    grep -A ${FLANK} -B ${FLANK} "${JMJ_QUERY_ALT}" B73.4genomes.blocks > blocks4

    echo "Created blocks4 with 4 genomes (missing CML457)"

else
    echo "No new genomes available. Using existing 3-genome setup."
fi

# ============================================================================
# STEP 4: Create layout file
# ============================================================================
echo ""
echo "=== Step 4: Create layout file ==="

if [ "$HAS_CML457" = true ] && [ "$HAS_CML459" = true ]; then
    cat > blocks5.layout << 'EOF'
# x,   y, rotation, ha, va, color, ratio, label
0.5, 0.2, 0, left, center, gold, 1, B73
0.5, 0.3, 0, left, center, indigo, 1, PT
0.5, 0.4, 0, left, center, indigo, 1, TIL18
0.5, 0.5, 0, left, center, green, 1, CML457
0.5, 0.6, 0, left, center, green, 1, CML459
# edges
e, 0, 1
e, 1, 2
e, 2, 3
e, 3, 4
EOF
    echo "Created blocks5.layout"
fi

# ============================================================================
# STEP 5: Add JMJ gene highlighting
# ============================================================================
echo ""
echo "=== Step 5: Add indigo* prefix for JMJ genes ==="

# The JMJ genes that should be highlighted (inversion-specific)
# Zm00001eb191790_T001 (jmj9), T006 (jmj6), T013 (jmj2)
# Zm00001eb191820_T001 (jmj4)
# Zm00001d051961_T002 (V4 ID)

if [ -f blocks5 ]; then
    # Add indigo* prefix to JMJ genes in B73 column
    perl -i -pe 's/^(Zm00001eb191790_T\d+)/indigo*$1/' blocks5
    perl -i -pe 's/^(Zm00001eb191820_T\d+)/indigo*$1/' blocks5
    perl -i -pe 's/^(Zm00001d051961_T\d+)/indigo*$1/' blocks5
    echo "Added indigo* prefix to JMJ genes in blocks5"
fi

# ============================================================================
# STEP 6: Merge BED files and generate figure
# ============================================================================
echo ""
echo "=== Step 6: Generate microsynteny figure ==="

if [ "$HAS_CML457" = true ] && [ "$HAS_CML459" = true ]; then
    # Merge all 5 BED files
    python3 -m jcvi.formats.bed merge B73.bed PT.bed mexicana.bed CML457.bed CML459.bed \
        -o B73_PT_mexicana_CML457_CML459.bed

    # Generate figure
    python3 -m jcvi.graphics.synteny blocks5 B73_PT_mexicana_CML457_CML459.bed blocks5.layout \
        --glyphstyle=arrow --genelabelsize=5 \
        --genelabels Zm00001eb191790_T013,Zm00001eb191820_T001,Zx00002aa015800_T001,Zm00109aa017906_T001

    echo ""
    echo "=== Output: blocks5.pdf ==="
    ls -la blocks5.pdf
fi

echo ""
echo "=== Done ==="
echo "Next: Copy blocks5.pdf to results/inversion_paper/figures/ for assembly"
