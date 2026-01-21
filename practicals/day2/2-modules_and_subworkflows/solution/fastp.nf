
process FASTP {
	
	input:
	tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
	
	output:
	tuple val(sample_id), val(fastq_set_id), path("${sample_id}-${fastq_R1_basename}-qced.fastq.gz"), path("${sample_id}-${fastq_R2_basename}-qced.fastq.gz"), emit: qced_reads
	tuple val(sample_id), path("${sample_id}-${fastq_R1_basename}_fastp.json"), emit: fastp_json
	tuple val(sample_id), path("${sample_id}-${fastq_R1_basename}_fastp.html"), emit: fastp_html
	tuple val("${task.process}"), val('fastp'), eval('fastp --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	fastq_R1_basename = fastq_R1.baseName.replace('.fastq', '')
	fastq_R2_basename = fastq_R2.baseName.replace('.fastq', '')
	"""
	fastp \
		-i ${fastq_R1} -o ${sample_id}-${fastq_R1_basename}-qced.fastq.gz \
		-I ${fastq_R2} -O ${sample_id}-${fastq_R2_basename}-qced.fastq.gz \
		--json ${sample_id}-${fastq_R1_basename}_fastp.json \
		--html ${sample_id}-${fastq_R1_basename}_fastp.html \
		--thread 4
	"""
}