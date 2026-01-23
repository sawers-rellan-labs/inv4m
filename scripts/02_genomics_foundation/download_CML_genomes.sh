#!/bin/bash
# Download CML457 and CML459 genome annotations from MaizeGDB
# for microsynteny analysis
#
# Files needed:
#   - GFF3 annotation
#   - CDS FASTA
#
# Run from: /Volumes/DOE_CAREER/inv4m/microsynteny/new_genomes/

set -e

OUTDIR="/Volumes/DOE_CAREER/inv4m/microsynteny/new_genomes"
BASE_URL="https://download.maizegdb.org"

mkdir -p "${OUTDIR}"
cd "${OUTDIR}"

echo "=== Downloading CML457 and CML459 annotations ==="
echo "Output directory: ${OUTDIR}"
echo ""

# CML457
echo "--- CML457 ---"
echo "GFF3..."
curl -O "${BASE_URL}/Zm-CML457-REFERENCE-HiLo-1.0/Zm-CML457-REFERENCE-HiLo-1.0_Zm00106aa.1.gff3.gz"
echo "CDS..."
curl -O "${BASE_URL}/Zm-CML457-REFERENCE-HiLo-1.0/Zm-CML457-REFERENCE-HiLo-1.0_Zm00106aa.1.cds.fa.gz"

# CML459
echo ""
echo "--- CML459 ---"
echo "GFF3..."
curl -O "${BASE_URL}/Zm-CML459-REFERENCE-HiLo-1.0/Zm-CML459-REFERENCE-HiLo-1.0_Zm00107aa.1.gff3.gz"
echo "CDS..."
curl -O "${BASE_URL}/Zm-CML459-REFERENCE-HiLo-1.0/Zm-CML459-REFERENCE-HiLo-1.0_Zm00107aa.1.cds.fa.gz"

echo ""
echo "=== Decompressing files ==="
gunzip -k *.gz

echo ""
echo "=== Downloaded files ==="
ls -lh "${OUTDIR}"

echo ""
echo "=== File naming summary ==="
echo "CML457 prefix: Zm00106aa"
echo "CML459 prefix: Zm00107aa"
echo ""
echo "Next: Run ../run_microsynteny_5genomes.sh"
