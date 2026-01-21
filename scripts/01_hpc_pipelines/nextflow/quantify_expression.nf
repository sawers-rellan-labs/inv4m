#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//
// QUANTIFY EXPRESSION PIPELINE
// Adapted from maizeRNA for PSU2022 dataset
//

// --- Parameters ---
params.seq_dir = null
params.ref_transcriptome = null
params.outdir = './results_quantify'


// --- Processes ---
process INDEX_TRANSCRIPTOME_KALLISTO {
    publishDir "${params.outdir}/kallisto_index", mode: 'copy'

    input:
    path ref_transcriptome

    output:
    path "transcriptome.idx"

    script:
    """
    kallisto index -i transcriptome.idx ${ref_transcriptome}
    """
}

process QUANT_KALLISTO {
    tag "${sample_id}"
    publishDir "${params.outdir}/kallisto_quant/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(fastq_1), path(fastq_2)
    path kallisto_index

    output:
    path sample_id

    script:
    """
    kallisto quant \
        -i ${kallisto_index} \
        -o ${sample_id} \
        -t ${task.cpus} \
        ${fastq_1} ${fastq_2}
    """
}

// --- Workflow ---
workflow {
    // Check for required parameters
    if (!params.seq_dir) { exit 1, "Parameter --seq_dir is required." }
    if (!params.ref_transcriptome) { exit 1, "Parameter --ref_transcriptome is required." }

    // Input Channel - pair FASTQ files by sample name
    // Illumina naming: L01_S1_L002_R1_001.fastq.gz / L01_S1_L002_R2_001.fastq.gz
    ch_samples_quantify = channel
        .fromFilePairs("${params.seq_dir}/*_R{1,2}_001.fastq.gz", size: 2)
        .map { sample_id, files ->
            tuple(sample_id, files[0], files[1])
        }

    // 1. Index Transcriptome with Kallisto
    ch_kallisto_index = INDEX_TRANSCRIPTOME_KALLISTO(file(params.ref_transcriptome))

    // 2. Quantify with Kallisto
    QUANT_KALLISTO(ch_samples_quantify, ch_kallisto_index)
}
