#!/bin/bash
#===============================================================================
# generate_jmj_blast_data.sh
#
# Purpose: Generate BLAST alignments for visualizing the JMJ cluster region
#          in the B73 maize genome. This script extracts the genomic region
#          containing the jmj2/jmj4 cluster and BLASTs it against candidate
#          cDNA sequences to show exon/intron structure.
#
# Region: Chr4:177,400,000-177,590,000 (190 kb window containing JMJ cluster)
#
# Outputs:
#   - B73_jmj_cluster_genomic.fas: Genomic sequence of the JMJ cluster region
#   - B73_jmj_cluster_genomic_vs_candidates_v5_cDNA.blast: BLAST results
#
# Requirements:
#   - BLAST+ suite (blastn, makeblastdb, blastdbcmd)
#   - B73 reference genome and cDNA databases
#   - JMJ candidate transcript list
#
# Usage:
#   ./generate_jmj_blast_data.sh --ref-dir /path/to/reference --out-dir /path/to/output
#
# Author: Sawers-Rellan Labs
# Date: January 2026
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------

# JMJ cluster coordinates (B73 NAM5)
CHROM="4"
START=177400000
END=177590000

# Default paths (can be overridden by command line arguments)
REF_DIR="${REF_DIR:-/System/Volumes/Data/ref/zea}"
OUT_DIR="${OUT_DIR:-$(pwd)}"
DATA_DIR="${DATA_DIR:-}"  # Optional: directory with existing cDNA fasta

# Reference files (relative to REF_DIR)
B73_GENOME_DB="Zea_mays.Zm-B73-REFERENCE-NAM-5.0.dna.toplevel"
B73_CDNA_DB="Zea_mays.Zm-B73-REFERENCE-NAM-5.0.cdna"
B73_V4_CDNA_DB="Zea_mays.B73_RefGen_v4.cdna"

# JMJ candidate transcripts (NAM5 annotation)
# These are the 5 JMJ paralogs in the cluster:
#   - Zm00001eb191790_T001 (jmj9)
#   - Zm00001eb191790_T006 (psi - pseudogene)
#   - Zm00001eb191790_T013 (jmj6)
#   - Zm00001eb191820_T001 (jmj4)
#   - Zm00001d051961_T002  (jmj2, from v4 annotation)
JMJ_CANDIDATES=(
    "Zm00001eb191790_T001"
    "Zm00001eb191790_T006"
    "Zm00001eb191790_T013"
    "Zm00001eb191820_T001"
)

# V4 transcript for jmj2 (not in NAM5 annotation properly)
JMJ2_V4_TRANSCRIPT="Zm00001d051961_T002"

#-------------------------------------------------------------------------------
# Parse command line arguments
#-------------------------------------------------------------------------------

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --ref-dir DIR    Directory containing BLAST databases (default: /System/Volumes/Data/ref/zea)"
    echo "  --out-dir DIR    Output directory for results (default: current directory)"
    echo "  --data-dir DIR   Directory with existing jmj_5_candidates_v5_cDNA.fasta (skips cDNA extraction)"
    echo "  --help           Show this help message"
    echo ""
    echo "Required BLAST databases in REF_DIR:"
    echo "  - ${B73_GENOME_DB}"
    echo "  - ${B73_CDNA_DB} (optional if --data-dir provided)"
    echo "  - ${B73_V4_CDNA_DB} (optional if --data-dir provided)"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --ref-dir)
            REF_DIR="$2"
            shift 2
            ;;
        --out-dir)
            OUT_DIR="$2"
            shift 2
            ;;
        --data-dir)
            DATA_DIR="$2"
            shift 2
            ;;
        --help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

#-------------------------------------------------------------------------------
# Validate environment
#-------------------------------------------------------------------------------

echo "=== JMJ Cluster BLAST Data Generation ==="
echo "Reference directory: ${REF_DIR}"
echo "Output directory: ${OUT_DIR}"
if [[ -n "${DATA_DIR}" ]]; then
    echo "Data directory: ${DATA_DIR}"
fi
echo "Region: Chr${CHROM}:${START}-${END}"
echo ""

# Check for BLAST+
if ! command -v blastn &> /dev/null; then
    echo "ERROR: blastn not found. Please install BLAST+ suite."
    exit 1
fi

if ! command -v blastdbcmd &> /dev/null; then
    echo "ERROR: blastdbcmd not found. Please install BLAST+ suite."
    exit 1
fi

# Check for reference databases
if [[ ! -f "${REF_DIR}/${B73_GENOME_DB}.nin" ]] && [[ ! -f "${REF_DIR}/${B73_GENOME_DB}.nal" ]]; then
    echo "ERROR: B73 genome BLAST database not found at ${REF_DIR}/${B73_GENOME_DB}"
    echo "Please create it with: makeblastdb -in genome.fa -out ${B73_GENOME_DB} -dbtype nucl -parse_seqids"
    exit 1
fi

# Create output directory
mkdir -p "${OUT_DIR}"

#-------------------------------------------------------------------------------
# Step 1: Extract JMJ cluster genomic region
#-------------------------------------------------------------------------------

echo "Step 1: Extracting JMJ cluster genomic region..."

GENOMIC_FASTA="${OUT_DIR}/B73_jmj_cluster_genomic.fas"

blastdbcmd \
    -db "${REF_DIR}/${B73_GENOME_DB}" \
    -entry "${CHROM}" \
    -range "${START}-${END}" \
    -out "${GENOMIC_FASTA}"

echo "  Created: ${GENOMIC_FASTA}"
echo "  Size: $(wc -c < "${GENOMIC_FASTA}") bytes"

#-------------------------------------------------------------------------------
# Step 2: Extract JMJ candidate cDNA sequences
#-------------------------------------------------------------------------------

echo ""
echo "Step 2: Extracting JMJ candidate cDNA sequences..."

CANDIDATES_FASTA="${OUT_DIR}/jmj_5_candidates_v5_cDNA.fasta"
CANDIDATES_LIST="${OUT_DIR}/jmj_candidates.list"

# Check if cDNA fasta already exists in data directory
if [[ -n "${DATA_DIR}" ]] && [[ -f "${DATA_DIR}/jmj_5_candidates_v5_cDNA.fasta" ]]; then
    echo "  Using existing cDNA fasta from data directory"
    cp "${DATA_DIR}/jmj_5_candidates_v5_cDNA.fasta" "${CANDIDATES_FASTA}"
    echo "  Copied: ${CANDIDATES_FASTA}"
else
    # Create candidate list file
    printf '%s\n' "${JMJ_CANDIDATES[@]}" > "${CANDIDATES_LIST}"

    # Extract NAM5 cDNA sequences
    if [[ -f "${REF_DIR}/${B73_CDNA_DB}.nin" ]] || [[ -f "${REF_DIR}/${B73_CDNA_DB}.nal" ]]; then
        blastdbcmd \
            -db "${REF_DIR}/${B73_CDNA_DB}" \
            -entry_batch "${CANDIDATES_LIST}" \
            -out "${CANDIDATES_FASTA}"
        echo "  Extracted ${#JMJ_CANDIDATES[@]} NAM5 transcripts"
    else
        echo "WARNING: NAM5 cDNA database not found, skipping NAM5 transcripts"
        touch "${CANDIDATES_FASTA}"
    fi

    # Add V4 jmj2 transcript (not properly annotated in NAM5)
    if [[ -f "${REF_DIR}/${B73_V4_CDNA_DB}.nin" ]] || [[ -f "${REF_DIR}/${B73_V4_CDNA_DB}.nal" ]]; then
        blastdbcmd \
            -db "${REF_DIR}/${B73_V4_CDNA_DB}" \
            -entry "${JMJ2_V4_TRANSCRIPT}" \
            >> "${CANDIDATES_FASTA}"
        echo "  Added V4 transcript: ${JMJ2_V4_TRANSCRIPT}"
    else
        echo "WARNING: V4 cDNA database not found, skipping ${JMJ2_V4_TRANSCRIPT}"
    fi

    echo "  Created: ${CANDIDATES_FASTA}"
fi

#-------------------------------------------------------------------------------
# Step 3: Create BLAST database from candidates
#-------------------------------------------------------------------------------

echo ""
echo "Step 3: Creating BLAST database from candidates..."

CANDIDATES_DB="${OUT_DIR}/jmj_5_candidates_v5_cDNA"

makeblastdb \
    -in "${CANDIDATES_FASTA}" \
    -out "${CANDIDATES_DB}" \
    -dbtype nucl \
    -parse_seqids \
    > /dev/null 2>&1

echo "  Created database: ${CANDIDATES_DB}"

#-------------------------------------------------------------------------------
# Step 4: Run BLAST alignment
#-------------------------------------------------------------------------------

echo ""
echo "Step 4: Running BLAST alignment..."

BLAST_OUTPUT="${OUT_DIR}/B73_jmj_cluster_genomic_vs_candidates_v5_cDNA.blast"

blastn \
    -task megablast \
    -query "${GENOMIC_FASTA}" \
    -db "${CANDIDATES_DB}" \
    -outfmt 6 \
    -out "${BLAST_OUTPUT}"

N_HITS=$(wc -l < "${BLAST_OUTPUT}")
echo "  Created: ${BLAST_OUTPUT}"
echo "  Number of hits: ${N_HITS}"

#-------------------------------------------------------------------------------
# Step 5: Clean up temporary files
#-------------------------------------------------------------------------------

echo ""
echo "Step 5: Cleaning up..."

# Remove temporary BLAST database files (keep the fasta)
rm -f "${CANDIDATES_DB}".n*
rm -f "${CANDIDATES_LIST}" 2>/dev/null || true

echo "  Removed temporary database files"

#-------------------------------------------------------------------------------
# Summary
#-------------------------------------------------------------------------------

echo ""
echo "=== Complete ==="
echo ""
echo "Output files:"
echo "  ${GENOMIC_FASTA}"
echo "  ${CANDIDATES_FASTA}"
echo "  ${BLAST_OUTPUT}"
echo ""
echo "These files can be used with plot_jmj_blast.Rmd for visualization."
