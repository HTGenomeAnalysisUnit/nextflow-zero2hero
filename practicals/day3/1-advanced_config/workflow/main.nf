include { BWA_MEM } from './modules/local/bwa'
include { SAMTOOLS_MERGE } from './modules/local/samtools-merge'
include { SAMTOOLS_SORT } from './modules/local/samtools-sort'

workflow {
	processed_genome = [ // fasta_file, fasta_dict, accessory_index_files
		file(params.reference_genome, checkIfExists: true),
		file("${params.reference_genome}.fai", checkIfExists: true),
		file("${params.reference_genome}.*", checkIfExists: true)
	]
	
	def row_counter = 0
	input_fastq_ch = channel.fromPath(params.input_file)
	.splitCsv(header:true, sep:'\t')
	.map { row ->
		row_counter += 1
		[
			sample_id: row.sample_id,
			fastq_set_id: "${row_counter}",
			fastq_R1: file(row.fastq_R1, checkIfExists: true), 
			fastq_R2: file(row.fastq_R2, checkIfExists: true)
		] 
	}
	
	bwa_input_ch = input_fastq_ch.combine(processed_genome)
	BWA_MEM(bwa_input_ch)

	bam_files_by_sample = BWA_MEM.out.bam_file
		.groupTuple(by: 0) // group by sample_id

	SAMTOOLS_MERGE(bam_files_by_sample)
	SAMTOOLS_SORT(SAMTOOLS_MERGE.out.merged_bam, 'dedup', 'coordinate')
}