process SAMTOOLS_MERGE {
	tag "${sample_id}"
	label 'process_low'

	publishDir "${params.outdir}/alignments/${sample_id}/merged_bam", mode: params.publish_mode

	container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'
	conda "${moduleDir}/environment.yml"
	
	input:
	tuple val(sample_id), file(bam_files)
	
	output:
	tuple val(sample_id), file("${sample_id}.merged_raw.bam"), emit: merged_bam
	tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	def bam_file_list = bam_files.collect { bam_file -> bam_file.name }.join(' ')
	"""
	samtools merge -n -@ ${task.cpus} -o ${sample_id}.merged_raw.bam ${bam_file_list}
	"""
}