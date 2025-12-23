include { BWA_MEM } from '../../modules/local/bwa'
include { SAMTOOLS_MERGE } from '../../modules/local/samtools-merge'
include { SAMBLASTER } from '../../modules/local/samblaster'
include { SAMTOOLS_SORT } from '../../modules/local/samtools-sort'

workflow ALIGN_AND_DEDUP {
	take:
		input_fastq // channel with tuples: sample_id, fastq_R1, fastq_R2

	main:
		reference_genome = tuple(file(params.reference_genome), file("${params.reference_genome}.*"))

		BWA_MEM(input_fastq, reference_genome)

		bam_files_by_sample = BWA_MEM.out.bam_file
			.groupTuple(by: 0) // group by sample_id

		SAMTOOLS_MERGE(bam_files_by_sample)		
		SAMBLASTER(SAMTOOLS_MERGE.out.merged_bam)
		SAMTOOLS_SORT(SAMBLASTER.out.dedup_bam, 'dedup', 'coordinate')

		final_bam_file = SAMTOOLS_SORT.out.sorted_bam

	emit:
		aligned_reads = final_bam_file // channel with tuples: sample_id, bam_file, bai_file
}