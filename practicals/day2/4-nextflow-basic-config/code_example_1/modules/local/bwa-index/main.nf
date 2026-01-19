process BWA_INDEX {
	tag "${genome_id}"
	label 'process_low'

	publishDir "${params.outdir}/genome_index", mode: params.publish_mode

	container 'community.wave.seqera.io/library/bwa_htslib_samtools:83b50ff84ead50d0'
	conda "${moduleDir}/environment.yml"
	
	input:
	tuple val(genome_id), path(fasta)
	
	output:
	tuple val(genome_id), path(fasta), path("${fasta}.*"),	emit: indexed_reference
	tuple val("${task.process}"), val('bwa'), eval('bwa 2>&1 | tail -n+3 | head -1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	bwa index ${fasta}
	"""
}