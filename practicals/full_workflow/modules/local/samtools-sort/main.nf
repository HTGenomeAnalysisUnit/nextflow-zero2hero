process SAMTOOLS_SORT {
	tag "${sample_id}"
	label 'process_low'

	publishDir "${params.outdir}/alignments/${sample_id}/merged_bam", mode: params.publish_mode

	container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'
	conda "${moduleDir}/environment.yml"
	
	input:
	tuple val(sample_id), file(bam_file)
	val(stage_name)
	val(sort_strategy) // e.g., 'name' or 'coordinate'
	
	output:
	tuple val(sample_id), file("${sample_id}.${stage_name}.sort-${sort_strategy}.bam"), file("${sample_id}.${stage_name}.sort-${sort_strategy}.bam.bai"), emit: sorted_bam
	tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	def sort_by_name = sort_strategy == 'name' ? '-n' : ''
	"""
	samtools sort -@ ${task.cpus} ${sort_by_name} -m ${(task.memory.toGiga() / task.cpus) - 1}G -o ${sample_id}.${stage_name}.sort-${sort_strategy}.bam ${bam_file}
	samtools index -b ${sample_id}.${stage_name}.sort-${sort_strategy}.bam
	"""
}