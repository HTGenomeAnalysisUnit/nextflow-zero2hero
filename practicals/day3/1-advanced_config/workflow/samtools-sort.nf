process SAMTOOLS_SORT {
	tag "${sample_id}"
	
	cpus 1
	memory 6.GB
	time 1.h

	publishDir "${params.outdir}/alignments/${sample_id}/merged_bam", mode: params.publish_mode

	container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'
	
	input:
	tuple val(sample_id), file(bam_file)
	val(stage_name)
	val(sort_strategy) // e.g., 'name' or 'coordinate'
	
	output:
	tuple val(sample_id), file("${sample_id}.${stage_name}.sort-${sort_strategy}.bam"), file("${sample_id}.${stage_name}.sort-${sort_strategy}.bam.bai"), emit: sorted_bam
	
	script:
	def sort_by_name = sort_strategy == 'name' ? '-n' : ''
	"""
	samtools sort -@ ${task.cpus} ${sort_by_name} -m ${(task.memory.toGiga() / task.cpus) - 1}G -o ${sample_id}.${stage_name}.sort-${sort_strategy}.bam ${bam_file}
	samtools index -b ${sample_id}.${stage_name}.sort-${sort_strategy}.bam
	"""
}