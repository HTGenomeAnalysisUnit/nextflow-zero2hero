nextflow.enable.dsl=2

process FASTP {
    publishDir "${params.outdir}/reads_qc/${sample_id}/fastp"
    container 'quay.io/biocontainers/fastp:1.0.1--heae3180_0'

    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)

    output:
    tuple val(sample_id), val(fastq_set_id), path("${sample_id}_${fastq_set_id}_R1_qced.fastq.gz"), path("${sample_id}_${fastq_set_id}_R2_qced.fastq.gz")
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

workflow {

    // Input TSV must have headers: sample_id, part, fastq_R1, fastq_R2
    Channel
        .fromPath(params.input_file)
        .splitCsv(header: true, sep: '\t')
        .map { row ->
            // Emit a TUPLE (most modules expect tuples, not maps)
            tuple(
                row.sample_id,
                row.part,
                file(row.fastq_R1, checkIfExists: true),
                file(row.fastq_R2, checkIfExists: true)
            )
        }
        .set { input_fastq_ch }
    // FASTP emits both qced_reads (used) and fastp_reports (optional)
    FASTP(input_fastq_ch)
}
