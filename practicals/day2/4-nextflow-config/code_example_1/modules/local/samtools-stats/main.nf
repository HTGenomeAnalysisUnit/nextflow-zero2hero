process SAMTOOLS_STATS {
	tag "${sample_id}"
	label 'process_low'

	publishDir "${params.outdir}/alignments/${sample_id}/alignment_qc", mode: params.publish_mode

	container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'
	conda "${moduleDir}/environment.yml"
	
	input:
	tuple val(sample_id), file(bam_file), file(bai_file)
	
	output:
	tuple val(sample_id), val("${bam_file}"), file("${bam_file}-stats.txt"), emit: stats_file
	tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	samtools stats --threads ${task.cpus} ${bam_file} > ${bam_file}-stats.txt
	"""
}