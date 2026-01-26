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
            --thread 4
    """
}

process BWA_MEM {

    publishDir "${params.outdir}/alignments/${sample_id}/bwa"

    container 'community.wave.seqera.io/library/bwa_htslib_samtools:83b50ff84ead50d0'

    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
    path reference_genome
    path bwa_index_ch 

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
    tuple val(sample_id), path(bam_files)
    
    output:
    tuple val(sample_id), path("${sample_id}.merged_raw.bam")
    
    script:
    """
    samtools merge -n -@ 4 -o ${sample_id}.merged_raw.bam ${bam_files}
    """
}

workflow {    
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
    reference_genome = file(params.reference_genome, checkIfExists: true)
    bwa_index_ch = Channel.fromPath("${params.reference_genome}.{amb,ann,bwt,pac,sa}", checkIfExists: true).collect()
    BWA_MEM(qc_reads_ch, reference_genome, bwa_index_ch)
    bam_files_by_sample = BWA_MEM.out.bam_file.groupTuple(by: 0)
    SAMTOOLS_MERGE(bam_files_by_sample)
}
