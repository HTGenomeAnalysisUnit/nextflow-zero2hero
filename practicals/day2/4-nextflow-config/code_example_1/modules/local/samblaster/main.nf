process SAMBLASTER {
	tag "${sample_id}"
	label 'process_low'

	container 'community.wave.seqera.io/library/htslib_samblaster_samtools:4c3c71996eda5794'
	conda "${moduleDir}/environment.yml"
	
	input:
	tuple val(sample_id), file(bam_file)
	
	output:
	tuple val(sample_id), file("${sample_id}.dedup-raw.bam"), emit: dedup_bam
	tuple val(sample_id), file("${sample_id}.dedup.log"), emit: dedup_log
	tuple val("${task.process}"), val('samblaster'), eval('samblaster --version 2>&1 | cut -d" " -f3'), topic: versions
	tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	samtools view -h $bam_file | samblaster --addMateTags 2> ${sample_id}.dedup.log | samtools view --threads ${task.cpus} -b - > ${sample_id}.dedup-raw.bam
	"""
}