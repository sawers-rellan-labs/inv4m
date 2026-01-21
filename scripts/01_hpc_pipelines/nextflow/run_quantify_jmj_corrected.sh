#!/bin/bash
#BSUB -J kallisto_jmj
#BSUB -o kallisto_jmj_%J.out
#BSUB -e kallisto_jmj_%J.err
#BSUB -n 1
#BSUB -R "rusage[mem=8GB]"
#BSUB -W 48:00
#BSUB -q sara

# Kallisto quantification for PSU2022 with JMJ-corrected cDNA
# Run from: /rsstu/users/r/rrellan/DOE_CAREER/inv4m/PSU2022/kallisto/
# Usage: bsub < run_quantify_jmj_corrected.sh

source ~/.bashrc
conda activate /share/maize/frodrig4/conda/env/nextflow

echo "========================================"
echo "Kallisto with JMJ-corrected cDNA"
echo "Dataset: PSU2022 (60 samples)"
echo "Started: $(date)"
echo "========================================"

# Clean previous failed run
rm -rf work/

nextflow run quantify_expression.nf \
  -c nextflow_jmj_corrected.config \
  -profile lsf \
  -with-report report_jmj_corrected.html \
  -with-timeline timeline_jmj_corrected.html

echo "========================================"
echo "Pipeline completed: $(date)"
echo "Output: ./quant_out_jmj_corrected/"
echo "========================================"
