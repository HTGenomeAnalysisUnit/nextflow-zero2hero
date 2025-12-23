process BWA_MEM {
	tag "${sample_id}"
	label 'process_high'

	publishDir "${params.outdir}/alignments/${sample_id}/bwa", pattern: '*.log', mode: params.publish_mode

	container 'community.wave.seqera.io/library/bwa_htslib_samtools:83b50ff84ead50d0'
	conda "${moduleDir}/environment.yml"
	
	input:
	tuple val(sample_id), file(fastq_R1), file(fastq_R2)
	tuple file(reference_genome), file(reference_genome_indexes) // A list containing genome.fa as first element and its indices
	
	output:
	tuple val(sample_id), file("${sample_id}-${task.index}.bwa.bam"), emit: bam_file
	tuple val(sample_id), file("${sample_id}-${task.index}.bwa.log"), emit: bwa_log
	tuple val("${task.process}"), val('bwa'), eval('bwa 2>&1 | tail -n+3 | head -1 | cut -d" " -f2'), topic: versions
	tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	bwa mem -t ${task.cpus} \
		-R \"@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:Illumina\" \
		${reference_genome} \
		${fastq_R1} ${fastq_R2} \
		2> ${sample_id}-${task.index}.bwa.log \
		| samtools view --threads ${task.cpus} -Sb - > ${sample_id}-${task.index}.bwa.bam
	"""
}