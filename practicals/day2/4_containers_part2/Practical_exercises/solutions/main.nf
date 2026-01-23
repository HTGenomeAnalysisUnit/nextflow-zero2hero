nextflow.enable.dsl=2

process FASTQC {
    publishDir "${params.outdir}/reads_qc/${sample_id}/fastqc"
    container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'

    input:
    tuple val(sample_id), path(fastq_R1), path(fastq_R2)

    output:
    tuple val(sample_id), path("*_fastqc.zip"), path("*_fastqc.html")

    script:
    """
    fastqc \
        --threads 4 \
        ${fastq_R1} \
        ${fastq_R2}
    """
}

workflow {

    // Input TSV must have headers: sample_id, fastq_R1, fastq_R2
    Channel
        .fromPath(params.input_file)
        .splitCsv(header: true, sep: '\t')
        .map { row ->
            // Emit a TUPLE (most modules expect tuples, not maps)
            tuple(
                row.sample_id,
                file(row.fastq_R1, checkIfExists: true),
                file(row.fastq_R2, checkIfExists: true)
            )
        }
        .set { input_fastq_ch }
    // READS_QC emits both qced_reads (used) and fastp_reports (optional)
    FASTQC(input_fastq_ch)
}
