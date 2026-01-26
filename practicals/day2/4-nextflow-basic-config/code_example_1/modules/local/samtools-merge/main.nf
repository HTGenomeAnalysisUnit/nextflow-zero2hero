process SAMTOOLS_MERGE {

	
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