nextflow.enable.dsl=2

process FASTP {
    publishDir "${params.outdir}/reads_qc/${sample_id}/fastp"
    container 'quay.io/biocontainers/fastp:1.0.1--heae3180_0'

    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)

    output:
    tuple val(sample_id), val(fastq_set_id), path("${sample_id}_${fastq_set_id}_R1_qced.fastq.gz"), path("${sample_id}_${fastq_set_id}_R2_qced.fastq.gz"), emit: qced_reads
    tuple val(sample_id), val(fastq_set_id), path("${sample_id}_${fastq_set_id}_fastp.json"), path("${sample_id}_${fastq_set_id}_fastp.html")

    script:
    """
    fastp \
            -i ${fastq_R1} -o ${sample_id}_${fastq_set_id}_R1_qced.fastq.gz \
            -I ${fastq_R2} -O ${sample_id}_${fastq_set_id}_R2_qced.fastq.gz \
            --json ${sample_id}_${fastq_set_id}_fastp.json \
            --html ${sample_id}_${fastq_set_id}_fastp.html \
            --thread ${task.cpus}
    """
}

process BWA_MEM {

    publishDir "${params.outdir}/alignments/${sample_id}/bwa"

    container 'community.wave.seqera.io/library/bwa_htslib_samtools:83b50ff84ead50d0'

    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2), path(reference_genome),  path(reference_genome_indexes) 

    output:
    tuple val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.bam"), emit: bam_file
    tuple val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.log")

    script:
    """
    bwa mem -t 4 \
            -R \"@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:Illumina\" \
            ${reference_genome} \
            ${fastq_R1} ${fastq_R2} \
            2> ${sample_id}-${fastq_set_id}.bwa.log \
            | samtools view --threads 4 -Sb - > ${sample_id}-${fastq_set_id}.bwa.bam
    """
}

process SAMTOOLS_MERGE {

    publishDir "${params.outdir}/alignments/${sample_id}/merged_bam"

    container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'
    
    input:
    tuple val(sample_id), file(bam_files)
    
    output:
    tuple val(sample_id), file("${sample_id}.merged_raw.bam")
    
    script:
    """
    samtools merge -n -@ ${task.cpus} -o ${sample_id}.merged_raw.bam ${bam_files}
    """
}

workflow {
    
    // FASTP emits both qced_reads (used) and fastp_reports (optional)
    Channel
        .fromPath(params.input_file)
        .splitCsv(header: true, sep: '\t')
        .map { row ->
            tuple(
                row.sample_id,
                row.part,
                file(row.fastq_R1, checkIfExists: true),
                file(row.fastq_R2, checkIfExists: true)
            )
        }
        .set { input_fastq_ch }
    FASTP(input_fastq_ch)
    qc_reads_ch = FASTP.out.qced_reads
    def ref_fa = file(params.reference_genome, checkIfExists: true)
    def bwa_indexes = [
    file("${params.reference_genome}.amb", checkIfExists: true),
    file("${params.reference_genome}.ann", checkIfExists: true),
    file("${params.reference_genome}.bwt", checkIfExists: true),
    file("${params.reference_genome}.pac", checkIfExists: true),
    file("${params.reference_genome}.sa",  checkIfExists: true)
        ]

    processed_genome = Channel.value(
        tuple(ref_fa, bwa_indexes)   // 2 items: fasta, list-of-index-files
        )
    // IMPORTANT: processed_genome must be a CHANNEL emitting ONE tuple    
    bwa_input_ch = qc_reads_ch.combine(processed_genome)
    BWA_MEM(bwa_input_ch)
    bam_files_by_sample = BWA_MEM.out.bam_file.groupTuple(by: 0)
    SAMTOOLS_MERGE(bam_files_by_sample)
}
