#!/bin/bash
# Replot 5-genome microsynteny with custom order and colors
# Uses original blocks5 file - only changes visual arrangement via layout
#
# Visual order (top to bottom): TIL18, PT, CML459, CML457, B73
# Colors: TIL18/PT/CML459/CML457 = indigo (Inv4m), B73 = gold (CTRL)
# No gene labels
#
# Usage: Copy this script and blocks5_visual_reorder.layout to the microsynteny directory, then run

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

echo "=== Replotting 5-Genome Microsynteny ==="

# Check required files
for f in blocks5 B73_PT_mexicana_CML457_CML459.bed blocks5_visual_reorder.layout; do
    if [ ! -f "$f" ]; then
        echo "ERROR: $f not found"
        exit 1
    fi
done

echo "=== Generate PDF figure ==="

python3 -m jcvi.graphics.synteny blocks5 B73_PT_mexicana_CML457_CML459.bed blocks5_visual_reorder.layout \
    --glyphstyle=arrow \
    --notex \
    --format pdf

# Rename output
if [ -f blocks5.pdf ]; then
    mv blocks5.pdf jmj_microsynteny_5genomes.pdf
fi

echo ""
ls -la jmj_microsynteny_5genomes.pdf
echo ""
echo "Done. Copy jmj_microsynteny_5genomes.pdf to results/inversion_paper/figures/"
