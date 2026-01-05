process SAMTOOLS_FAIDX {
	tag "${genome_id}"
	label 'process_low'

	publishDir "${params.outdir}/genome_index", mode: params.publish_mode

	container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'
	conda "${moduleDir}/environment.yml"
	
	input:
	tuple val(genome_id), path(fasta)
	
	output:
	tuple val(genome_id), path(fasta), path("${fasta}.fai"),	emit: genome_fai
	tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	samtools faidx ${fasta}
	"""
}