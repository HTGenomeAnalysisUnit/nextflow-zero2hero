
process FASTP {
    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
    
    output:
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz")
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html")
    
    script:
    fastq_R1_basename = fastq_R1.baseName.replace('.fastq', '')
    fastq_R2_basename = fastq_R2.baseName.replace('.fastq', '')
    """
    fastp \
        -i ${fastq_R1} -o ${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz \
        -I ${fastq_R2} -O ${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz \
        --json ${fastq_R1_basename}-${fastq_set_id}_fastp.json \
        --html ${fastq_R1_basename}-${fastq_set_id}_fastp.html \
        --thread ${task.cpus}
    """
}

workflow {

    // Read samplesheet with the sample ids and fastq paths
    def row_counter = 0
	input_fastq_ch = channel.fromPath(params.input_file)
		.splitCsv(header:true, sep:'\t')
		.map { row ->
			row_counter += 1
			[
				sample_id: row.sample_id,
				fastq_set_id: "${row_counter}",
				fastq_R1: file(row.fastq_R1, checkIfExists: true), 
				fastq_R2: file(row.fastq_R2, checkIfExists: true)
			] 
		}
    

    FASTP(input_fastq_ch)
}