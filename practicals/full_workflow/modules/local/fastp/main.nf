process FASTP {
	tag "${sample_id}"
	label 'process_low'
	
	publishDir "${params.outdir}/reads_qc/${sample_id}/fastp", mode: params.publish_mode

	container 'quay.io/biocontainers/fastp:1.0.1--heae3180_0'
	conda "${moduleDir}/environment.yml"
	
	input:
	tuple val(sample_id), file(fastq_R1), file(fastq_R2)
	
	output:
	tuple val(sample_id), file("${fastq_R1_basename}-qced.fastq.gz"), file("${fastq_R2_basename}-qced.fastq.gz"), emit: qced_reads
	tuple val(sample_id), file("${fastq_R1_basename}_fastp.json"), file("${fastq_R1_basename}_fastp.html"), emit: fastp_reports
	tuple val("${task.process}"), val('fastp'), eval('fastp --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	fastq_R1_basename = fastq_R1.baseName.replace('.fastq', '')
	fastq_R2_basename = fastq_R2.baseName.replace('.fastq', '')
	"""
	fastp \
		-i ${fastq_R1} -o ${fastq_R1_basename}-qced.fastq.gz \
		-I ${fastq_R2} -O ${fastq_R2_basename}-qced.fastq.gz \
		--json ${fastq_R1_basename}_fastp.json \
		--html ${fastq_R1_basename}_fastp.html \
		--thread ${task.cpus}
	"""
}