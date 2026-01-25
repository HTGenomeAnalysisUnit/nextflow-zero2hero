process RDEVAL {
	label 'process_low'
	
	// Here we use a pre-compiled binary provided directly in the bin folder

	input:
	tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)

	output:
	tuple val(sample_id), path("*-rdeval_report.tsv"), emit: rdeval_report
	tuple val("${task.process}"), val('rdeval'), eval('rdeval --version | head -n 1 | cut -d" " -f2'), topic: versions

	script:
	fastq_R1_basename = fastq_R1.baseName.replace('.fastq', '')
	fastq_R2_basename = fastq_R2.baseName.replace('.fastq', '')
	"""
	rdeval --sequence-report --tabular --threads ${task.cpus} ${fastq_R1} > ${fastq_R1_basename}-${fastq_set_id}-rdeval_report.tsv
	rdeval --sequence-report --tabular --threads ${task.cpus} ${fastq_R2} > ${fastq_R2_basename}-${fastq_set_id}-rdeval_report.tsv
	"""
}