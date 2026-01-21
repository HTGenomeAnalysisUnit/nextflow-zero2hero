include { BWA_MEM } from './bwa.nf'
include { SAMTOOLS_MERGE } from './samtools-merge.nf'
include { SAMTOOLS_SORT } from './samtools-sort.nf'

workflow {
	// Define channels
	processed_genome = channel.of(params.reference_genome) 
	.map { fasta_file ->
		[
			file(fasta_file, checkIfExists: true),
			file(fasta_file.replaceAll(/\.fa$/, '.dict'), checkIfExists: true),
			file("${fasta_file}.*", checkIfExists: true)
		]
	} // fasta_file, fasta_dict, accessory_index_files
	

	def row_counter = 0
	input_fastq_ch = channel.fromPath(params.input_file)
	.splitCsv(header:true, sep:'\t')
	.map { row ->
		row_counter += 1
		[
			row.sample_id,
			"${row_counter}",
			file(row.fastq_R1, checkIfExists: true), 
			file(row.fastq_R2, checkIfExists: true)
		] 
	}
	
	bwa_input_ch = input_fastq_ch.combine(processed_genome)
	BWA_MEM(bwa_input_ch)

	bam_files_by_sample = BWA_MEM.out.bam_file
		.groupTuple(by: 0) // group by sample_id

	SAMTOOLS_MERGE(bam_files_by_sample)
	SAMTOOLS_SORT(SAMTOOLS_MERGE.out.merged_bam, 'dedup', 'coordinate')
}