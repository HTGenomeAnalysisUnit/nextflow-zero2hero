process BWA_MEM {
	tag "${sample_id}"
	label 'process_high'
	label 'process_high_memory'
	
	publishDir "${params.outdir}/alignments/${sample_id}/bwa", pattern: '*.log', mode: params.publish_mode

	container 'community.wave.seqera.io/library/bwa_htslib_samtools:83b50ff84ead50d0'
	
	input:
	tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2), path(reference_genome), path(reference_genome_dict), path(reference_genome_indexes) 

	output:
	tuple val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.bam"), emit: bam_file
	tuple val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.log"), emit: bwa_log
	
	script:
	"""
	bwa mem -t ${task.cpus} \
		-R \"@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:Illumina\" \
		${reference_genome} \
		${fastq_R1} ${fastq_R2} \
		2> ${sample_id}-${fastq_set_id}.bwa.log \
		| samtools view --threads ${task.cpus} -Sb - > ${sample_id}-${fastq_set_id}.bwa.bam
	"""
}