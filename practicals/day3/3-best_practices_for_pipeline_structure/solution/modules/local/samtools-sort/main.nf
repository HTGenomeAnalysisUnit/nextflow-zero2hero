process SAMTOOLS_SORT {
	label 'process_medium'
	
	input:
	tuple val(sample_id), file(bam_file)
	
	output:
	tuple val(sample_id), file("${sample_id}.sort.bam"), file("${sample_id}.sort.bam.bai"), emit: sorted_bam
	tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	samtools sort -@ 4 -m 2G -o ${sample_id}.sort.bam ${bam_file}
	samtools index -b ${sample_id}.sort.bam
	"""
}