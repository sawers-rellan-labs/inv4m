#!/bin/bash
#BSUB -J genotype_rnaseq
#BSUB -o genotype_rnaseq_%J.out
#BSUB -e genotype_rnaseq_%J.err
#BSUB -n 1
#BSUB -R "rusage[mem=8GB]"
#BSUB -W 72:00
#BSUB -q sara

# RNA-seq germline SNP genotyping pipeline
# Run from: the directory containing your samplesheet
#
# Usage:
#   Edit the PATH CONFIGURATION block below, then:
#   bsub < run_genotype.sh

set -euo pipefail

# ============================================================
# PATH CONFIGURATION — edit these for your run
# ============================================================

GENOME="/rsstu/users/r/rrellan/sara/ref/Zm-B73-REFERENCE-NAM-5.0.fa"
GENOME_FAI="${GENOME}.fai"
GENOME_DICT="/rsstu/users/r/rrellan/sara/ref/Zm-B73-REFERENCE-NAM-5.0.dict"
STAR_INDEX="/rsstu/users/r/rrellan/sara/ref/NAM5_CHR"
GTF="/rsstu/users/r/rrellan/sara/ref/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.56.gtf"
KNOWN_SITES="/rsstu/users/r/rrellan/sara/ref/zea_mays.vcf.gz"
KNOWN_SITES_IDX="${KNOWN_SITES}.tbi"
SAMPLESHEET="samplesheet.csv"
OUTDIR="./results"

# Optional: gene interval list for GenotypeGVCFs (leave empty to skip)
INTERVALS=""

# Conda environment with Nextflow installed
NEXTFLOW_ENV="/share/maize/frodrig4/conda/env/nextflow"

# Conda environments for tools (path or name)
CONDA_STAR="/share/maize/frodrig4/conda/env/star"
CONDA_GATK="/share/maize/frodrig4/conda/env/gatk"
CONDA_BCFTOOLS="/share/maize/frodrig4/conda/env/bcftools"

# ============================================================
# LAUNCH
# ============================================================

source ~/.bashrc
conda activate "${NEXTFLOW_ENV}"

PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================================"
echo "RNA-seq Germline Genotyping Pipeline"
echo "Samplesheet : ${SAMPLESHEET}"
echo "Output      : ${OUTDIR}"
echo "Started     : $(date)"
echo "========================================================"

# Build optional intervals argument
INTERVALS_ARG=""
if [[ -n "${INTERVALS}" ]]; then
    INTERVALS_ARG="--intervals ${INTERVALS}"
fi

nextflow run "${PIPELINE_DIR}/genotype_rnaseq.nf" \
    -c "${PIPELINE_DIR}/genotype_rnaseq.config" \
    -profile lsf \
    -resume \
    --samplesheet    "${SAMPLESHEET}" \
    --genome         "${GENOME}" \
    --genome_fai     "${GENOME_FAI}" \
    --genome_dict    "${GENOME_DICT}" \
    --star_index     "${STAR_INDEX}" \
    --gtf            "${GTF}" \
    --known_sites    "${KNOWN_SITES}" \
    --known_sites_idx "${KNOWN_SITES_IDX}" \
    --outdir         "${OUTDIR}" \
    --conda_star     "${CONDA_STAR}" \
    --conda_gatk     "${CONDA_GATK}" \
    --conda_bcftools "${CONDA_BCFTOOLS}" \
    ${INTERVALS_ARG}

echo "========================================================"
echo "Pipeline completed : $(date)"
echo "Final VCF          : ${OUTDIR}/vcf/snps_pass.vcf.gz"
echo "Reports            : ${OUTDIR}/pipeline_info/"
echo "========================================================"
