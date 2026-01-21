process SAMTOOLS_STATS {
	
	input:
	tuple val(sample_id), file(bam_file), file(bai_file)
	
	output:
	tuple val(sample_id), val("${bam_file}"), file("${bam_file}-stats.txt"), emit: stats_file
	tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	samtools stats --threads 4 ${bam_file} > ${bam_file}-stats.txt
	"""
}