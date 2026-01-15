process BWA_MEM {
	
	input:
	tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2), val(genome_id), path(genome_fasta), path(genome_indexes)

	output:
	tuple val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.bam"), emit: bam_file
	tuple val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.log"), emit: bwa_log
	tuple val("${task.process}"), val('bwa'), eval('bwa 2>&1 | tail -n+3 | head -1 | cut -d" " -f2'), topic: versions
	tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	bwa mem -t 4 \
		-R \"@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:Illumina\" \
		${genome_fasta} \
		${fastq_R1} ${fastq_R2} \
		2> ${sample_id}-${fastq_set_id}.bwa.log \
		| samtools view --threads 4 -Sb - > ${sample_id}-${fastq_set_id}.bwa.bam
	"""
}