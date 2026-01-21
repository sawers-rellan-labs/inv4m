#!/bin/bash
#BSUB -J kallisto_psu2022
#BSUB -o kallisto_psu2022_%J.out
#BSUB -e kallisto_psu2022_%J.err
#BSUB -n 1
#BSUB -R "rusage[mem=8GB]"
#BSUB -W 48:00
#BSUB -q sara

# Kallisto quantification for PSU2022 dataset
# Run from: /rsstu/users/r/rrellan/DOE_CAREER/inv4m/PSU2022/kallisto/
# Usage: cd /rsstu/users/r/rrellan/DOE_CAREER/inv4m/PSU2022/kallisto && bsub < run_quantify_psu2022.sh

# Activate nextflow environment (for pipeline orchestration)
source ~/.bashrc
conda activate /share/maize/frodrig4/conda/env/nextflow

echo "========================================"
echo "Running Kallisto Quantification Pipeline"
echo "Dataset: PSU2022"
echo "Started: $(date)"
echo "========================================"

# Run pipeline
nextflow run quantify_expression.nf \
  -c nextflow.config \
  -profile lsf \
  -resume \
  -with-report report_psu2022.html \
  -with-timeline timeline_psu2022.html

echo "========================================"
echo "Pipeline completed: $(date)"
echo "Check job status with 'bjobs'"
echo "Output: ./quant_out/"
echo "========================================"
