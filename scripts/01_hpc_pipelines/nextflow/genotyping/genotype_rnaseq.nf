#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// ============================================================
// GENOTYPE_RNASEQ
// GATK4 RNA-seq germline SNP calling pipeline
// Follows GATK4 best practices for RNA-seq variant discovery
// Adapted from inv4m bash scripts (tcsh one-per-step originals)
// ============================================================

if (params.help) {
    log.info """
    |=======================================================
    | GENOTYPE_RNASEQ — GATK4 RNA-seq germline SNP pipeline
    |=======================================================
    |
    | Usage:
    |   nextflow run genotype_rnaseq.nf \\
    |     -c genotype_rnaseq.config -profile lsf \\
    |     --samplesheet    samples.csv \\
    |     --genome         /path/to/Zm-B73-NAM-5.0.fa \\
    |     --genome_fai     /path/to/Zm-B73-NAM-5.0.fa.fai \\
    |     --genome_dict    /path/to/Zm-B73-NAM-5.0.dict \\
    |     --star_index     /path/to/NAM5_CHR/ \\
    |     --gtf            /path/to/Zea_mays.56.gtf \\
    |     --known_sites    /path/to/zea_mays.vcf.gz \\
    |     --known_sites_idx /path/to/zea_mays.vcf.gz.tbi \\
    |     --outdir         ./results
    |
    | Samplesheet (CSV with header row):
    |   sample_id,library_id,fastq_1,fastq_2
    |   3056,L01_S1,/data/L01_R1_001.fastq.gz,/data/L01_R2_001.fastq.gz
    |
    | Optional parameters:
    |   --intervals     gene interval list (for GenotypeGVCFs scatter)
    |   --chromosomes   comma-separated chr list for BQSR scatter (default: 1..10)
    |   --outdir        output directory (default: ./results)
    """.stripMargin()
    exit 0
}

// --- Validate required parameters ---
['samplesheet', 'genome', 'genome_fai', 'genome_dict',
 'star_index', 'gtf', 'known_sites', 'known_sites_idx'].each { p ->
    if (!params[p]) { exit 1, "ERROR: --${p} is required. Run with --help for usage." }
}

// ============================================================
// PROCESSES
// ============================================================

process STAR_ALIGN {
    tag "${sample_id}:${library_id}"
    publishDir "${params.outdir}/qc/star/${library_id}", mode: 'copy',
               pattern: '*Log.final.out'

    conda params.conda_star
    cpus   params.star_cpus
    memory params.star_mem
    time   params.star_time
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(sample_id), val(library_id), path(fastq_1), path(fastq_2)
    path star_index
    path gtf

    output:
    tuple val(sample_id), val(library_id),
          path("${library_id}Aligned.sortedByCoord.out.bam"), emit: bam
    path "${library_id}Log.final.out", emit: log

    script:
    """
    STAR \\
        --runThreadN ${task.cpus} \\
        --genomeDir ${star_index} \\
        --sjdbGTFfile ${gtf} \\
        --readFilesCommand zcat \\
        --readFilesIn ${fastq_1} ${fastq_2} \\
        --outSAMtype BAM SortedByCoordinate \\
        --outFileNamePrefix ${library_id} \\
        --outReadsUnmapped Fastx
    """
}

process ADD_READ_GROUPS {
    tag "${sample_id}:${library_id}"

    conda params.conda_gatk
    cpus   1
    memory '4 GB'
    time   '1h'
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(sample_id), val(library_id), path(bam)

    output:
    tuple val(sample_id), val(library_id), path("${library_id}_rg.bam"), emit: bam

    script:
    """
    picard AddOrReplaceReadGroups \\
        -I  ${bam} \\
        -O  ${library_id}_rg.bam \\
        -SO coordinate \\
        -RGID ${library_id} \\
        -RGLB ${library_id} \\
        -RGPL illumina \\
        -RGPU ${library_id} \\
        -RGSM ${sample_id}
    """
}

process MARK_DUPLICATES {
    tag "${sample_id}:${library_id}"
    publishDir "${params.outdir}/qc/markdup", mode: 'copy',
               pattern: '*.metrics.txt'

    conda params.conda_gatk
    cpus   1
    memory '8 GB'
    time   '2h'
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(sample_id), val(library_id), path(bam)

    output:
    tuple val(sample_id), val(library_id),
          path("${library_id}_dedup.bam"),
          path("${library_id}_dedup.bai"), emit: bam
    path "${library_id}.metrics.txt", emit: metrics

    script:
    """
    picard MarkDuplicates \\
        -I  ${bam} \\
        -O  ${library_id}_dedup.bam \\
        -M  ${library_id}.metrics.txt \\
        -CREATE_INDEX true \\
        -VALIDATION_STRINGENCY SILENT
    """
}

process SPLIT_N_CIGAR {
    tag "${sample_id}:${library_id}"

    conda params.conda_gatk
    cpus   1
    memory '8 GB'
    time   '2h'
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(sample_id), val(library_id), path(bam), path(bai)
    path genome
    path genome_fai
    path genome_dict

    output:
    tuple val(sample_id), val(library_id),
          path("${library_id}_split.bam"),
          path("${library_id}_split.bai"), emit: bam

    script:
    """
    gatk SplitNCigarReads \\
        --use-original-qualities \\
        -R ${genome} \\
        -I ${bam} \\
        -O ${library_id}_split.bam
    """
}

// Scatter BaseRecalibrator across chromosomes; receives ALL split BAMs jointly.
// The chromosome scatter + collect() pattern produces one recal table per chr,
// then GATHER_BQSR_REPORTS merges them.
process BASE_RECALIBRATOR {
    tag "chr${chromosome}"

    conda params.conda_gatk
    cpus   2
    memory '16 GB'
    time   '12h'
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(chromosome), path(split_bams), path(split_bais)
    path genome
    path genome_fai
    path genome_dict
    path known_sites
    path known_sites_idx

    output:
    path "chr${chromosome}_recal.table", emit: table

    script:
    def bam_inputs = (split_bams instanceof List ? split_bams : [split_bams])
        .collect { "-I ${it}" }.join(" \\\n        ")
    """
    gatk BaseRecalibrator \\
        -R ${genome} \\
        --known-sites ${known_sites} \\
        --use-original-qualities \\
        --intervals ${chromosome} \\
        ${bam_inputs} \\
        -O chr${chromosome}_recal.table
    """
}

process GATHER_BQSR_REPORTS {
    conda params.conda_gatk
    cpus   1
    memory '4 GB'
    time   '1h'

    input:
    path recal_tables

    output:
    path "recal.table", emit: table

    script:
    def table_inputs = (recal_tables instanceof List ? recal_tables : [recal_tables])
        .collect { "-I ${it}" }.join(" \\\n        ")
    """
    gatk GatherBQSRReports \\
        ${table_inputs} \\
        -O recal.table
    """
}

process APPLY_BQSR {
    tag "${sample_id}:${library_id}"

    conda params.conda_gatk
    cpus   1
    memory '8 GB'
    time   '2h'
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(sample_id), val(library_id), path(bam), path(bai)
    path recal_table
    path genome
    path genome_fai
    path genome_dict

    output:
    tuple val(sample_id), val(library_id),
          path("${library_id}_recal.bam"),
          path("${library_id}_recal.bai"), emit: bam

    script:
    """
    gatk ApplyBQSR \\
        -R ${genome} \\
        -I ${bam} \\
        --bqsr-recal-file ${recal_table} \\
        -O ${library_id}_recal.bam
    """
}

// One GVCF per sample (biological sample_id, not library_id).
// Read group RGSM set during ADD_READ_GROUPS encodes the sample identity.
process HAPLOTYPE_CALLER {
    tag "${sample_id}"

    conda params.conda_gatk
    cpus   2
    memory '8 GB'
    time   '4h'
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple val(sample_id), val(library_id), path(bam), path(bai)
    path genome
    path genome_fai
    path genome_dict

    output:
    path "${sample_id}.g.vcf.gz",     emit: gvcf
    path "${sample_id}.g.vcf.gz.tbi", emit: tbi

    script:
    """
    gatk --java-options "-Xmx${(task.memory.toGiga() - 1)}g" HaplotypeCaller \\
        -R ${genome} \\
        -I ${bam} \\
        --dont-use-soft-clipped-bases \\
        --stand-call-conf 20.0 \\
        -ERC GVCF \\
        -O ${sample_id}.g.vcf.gz
    """
}

process COMBINE_GVCFS {
    conda params.conda_gatk
    cpus   2
    memory '16 GB'
    time   '4h'
    errorStrategy 'retry'
    maxRetries 2

    input:
    path gvcfs
    path tbis
    path genome
    path genome_fai
    path genome_dict

    output:
    tuple path("combined.g.vcf.gz"), path("combined.g.vcf.gz.tbi"), emit: gvcf

    script:
    def gvcf_inputs = (gvcfs instanceof List ? gvcfs : [gvcfs])
        .collect { "-V ${it}" }.join(" \\\n        ")
    """
    gatk --java-options "-Xmx${(task.memory.toGiga() - 1)}g" CombineGVCFs \\
        -R ${genome} \\
        ${gvcf_inputs} \\
        -O combined.g.vcf.gz
    """
}

process GENOTYPE_GVCFS {
    publishDir "${params.outdir}/vcf", mode: 'copy'

    conda params.conda_gatk
    cpus   2
    memory '16 GB'
    time   '4h'
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple path(gvcf), path(tbi)
    path genome
    path genome_fai
    path genome_dict

    output:
    tuple path("raw.vcf.gz"), path("raw.vcf.gz.tbi"), emit: vcf

    script:
    def intervals_arg = params.intervals
        ? "--force-output-intervals ${params.intervals}"
        : ''
    """
    gatk --java-options "-Xmx${(task.memory.toGiga() - 1)}g" GenotypeGVCFs \\
        -R ${genome} \\
        -V ${gvcf} \\
        ${intervals_arg} \\
        -O raw.vcf.gz
    """
}

process SELECT_VARIANTS {
    conda params.conda_gatk
    cpus   1
    memory '8 GB'
    time   '2h'
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple path(vcf), path(tbi)
    path genome
    path genome_fai
    path genome_dict

    output:
    tuple path("biallelic_snps.vcf.gz"), path("biallelic_snps.vcf.gz.tbi"), emit: vcf

    script:
    """
    gatk --java-options "-Xmx${(task.memory.toGiga() - 1)}g" SelectVariants \\
        -R ${genome} \\
        -V ${vcf} \\
        -select-type SNP \\
        --restrict-alleles-to BIALLELIC \\
        -O biallelic_snps.vcf.gz
    """
}

process VARIANT_FILTRATION {
    conda params.conda_gatk
    cpus   1
    memory '8 GB'
    time   '2h'
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple path(vcf), path(tbi)
    path genome
    path genome_fai
    path genome_dict

    output:
    tuple path("filtered_snps.vcf.gz"), path("filtered_snps.vcf.gz.tbi"), emit: vcf

    script:
    """
    gatk --java-options "-Xmx${(task.memory.toGiga() - 1)}g" VariantFiltration \\
        -R ${genome} \\
        -V ${vcf} \\
        --window 35 \\
        --cluster 3 \\
        -filter "QD < 2.0"  --filter-name "QD2" \\
        -filter "FS > 30.0" --filter-name "FS30" \\
        -filter "SOR > 3.0" --filter-name "SOR3" \\
        -filter "MQ < 40.0" --filter-name "MQ40" \\
        -O filtered_snps.vcf.gz
    """
}

process BCFTOOLS_PASS {
    publishDir "${params.outdir}/vcf", mode: 'copy'

    conda params.conda_bcftools
    cpus   1
    memory '4 GB'
    time   '1h'

    input:
    tuple path(vcf), path(tbi)

    output:
    path "snps_pass.vcf.gz",     emit: vcf
    path "snps_pass.vcf.gz.tbi", emit: tbi

    script:
    """
    bcftools view --apply-filters .,PASS ${vcf} | bgzip -c > snps_pass.vcf.gz
    tabix -p vcf snps_pass.vcf.gz
    """
}

// ============================================================
// WORKFLOW
// ============================================================

workflow {

    // --- Input channels ---
    ch_samples = Channel
        .fromPath(params.samplesheet, checkIfExists: true)
        .splitCsv(header: true)
        .map { row -> tuple(row.sample_id, row.library_id,
                            file(row.fastq_1, checkIfExists: true),
                            file(row.fastq_2, checkIfExists: true)) }

    // Reference files — staged together so GATK finds .fai and .dict alongside .fa
    ch_genome       = file(params.genome,        checkIfExists: true)
    ch_genome_fai   = file(params.genome_fai,    checkIfExists: true)
    ch_genome_dict  = file(params.genome_dict,   checkIfExists: true)
    ch_star_index   = file(params.star_index,    checkIfExists: true)
    ch_gtf          = file(params.gtf,           checkIfExists: true)
    ch_known_sites  = file(params.known_sites,   checkIfExists: true)
    ch_known_sites_idx = file(params.known_sites_idx, checkIfExists: true)

    // Chromosome list for BQSR scatter
    ch_chromosomes = Channel.from(params.chromosomes.tokenize(',').collect { it.trim() })

    // --- Per-library steps ---
    STAR_ALIGN(ch_samples, ch_star_index, ch_gtf)
    ADD_READ_GROUPS(STAR_ALIGN.out.bam)
    MARK_DUPLICATES(ADD_READ_GROUPS.out.bam)
    SPLIT_N_CIGAR(
        MARK_DUPLICATES.out.bam,
        ch_genome, ch_genome_fai, ch_genome_dict
    )

    // --- Joint BQSR: scatter across chromosomes ---
    // Collect all split BAMs/BAIs into single-element channels (value channels),
    // then combine with the chromosome queue so each chr gets all BAMs.
    ch_all_bams = SPLIT_N_CIGAR.out.bam.map { sid, lid, bam, bai -> bam }.collect()
    ch_all_bais = SPLIT_N_CIGAR.out.bam.map { sid, lid, bam, bai -> bai }.collect()

    ch_bqsr_scatter = ch_chromosomes
        .combine(ch_all_bams)
        .combine(ch_all_bais)

    BASE_RECALIBRATOR(
        ch_bqsr_scatter,
        ch_genome, ch_genome_fai, ch_genome_dict,
        ch_known_sites, ch_known_sites_idx
    )

    GATHER_BQSR_REPORTS(BASE_RECALIBRATOR.out.table.collect())

    // --- Per-library BQSR application and genotyping ---
    APPLY_BQSR(
        SPLIT_N_CIGAR.out.bam,
        GATHER_BQSR_REPORTS.out.table,
        ch_genome, ch_genome_fai, ch_genome_dict
    )

    HAPLOTYPE_CALLER(
        APPLY_BQSR.out.bam,
        ch_genome, ch_genome_fai, ch_genome_dict
    )

    // --- Joint genotyping ---
    COMBINE_GVCFS(
        HAPLOTYPE_CALLER.out.gvcf.collect(),
        HAPLOTYPE_CALLER.out.tbi.collect(),
        ch_genome, ch_genome_fai, ch_genome_dict
    )

    GENOTYPE_GVCFS(
        COMBINE_GVCFS.out.gvcf,
        ch_genome, ch_genome_fai, ch_genome_dict
    )

    // --- Variant filtering ---
    SELECT_VARIANTS(
        GENOTYPE_GVCFS.out.vcf,
        ch_genome, ch_genome_fai, ch_genome_dict
    )

    VARIANT_FILTRATION(
        SELECT_VARIANTS.out.vcf,
        ch_genome, ch_genome_fai, ch_genome_dict
    )

    BCFTOOLS_PASS(VARIANT_FILTRATION.out.vcf)
}
