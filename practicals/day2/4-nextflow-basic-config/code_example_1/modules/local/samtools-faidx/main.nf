process SAMTOOLS_FAIDX {
	
	publishDir "${params.outdir}/genome_index", mode: params.publish_mode

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