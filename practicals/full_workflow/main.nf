include { PREPARE_GENOME } from './workflows/prepare-genome'
include { READS_QC } from './workflows/reads-qc'
include { ALIGN_AND_DEDUP } from './workflows/align'
include { ALIGNMENT_QC } from './workflows/align-qc'
include { CALL_VARIANTS } from './workflows/variant-call'

workflow {
	// if params.chromosomes is null, get all canonical chromosomes otherwise make a list from the param
	chromosome_list = params.variant_chromosomes ? params.variant_chromosomes.split(',') : [1..22, 'X', 'Y', 'M'].collect { chrom -> "chr${chrom.toString()}" }
	
	PREPARE_GENOME(params.reference_genome)
	processed_genome = PREPARE_GENOME.out.processed_genome
	
	def row_counter = 0
	input_fastq_ch = channel.fromPath(params.input_file)
		.splitCsv(header:true, sep:'\t')
		.map { row ->
			row_counter++
			[
				sample_id: row.sample_id,
				fastq_set_id: "${row_counter}",
				fastq_R1: file(row.fastq_R1, checkIfExists: true), 
				fastq_R2: file(row.fastq_R2, checkIfExists: true)
			] 
		}

	READS_QC(input_fastq_ch)
	
	qc_reads_ch = READS_QC.out.qced_reads
	ALIGN_AND_DEDUP(qc_reads_ch, processed_genome)

	bam_per_sample_ch = ALIGN_AND_DEDUP.out.aligned_reads
	ALIGNMENT_QC(bam_per_sample_ch)

	// TODO: Add entry point for BAM file input to perform only variant calling
	CALL_VARIANTS(bam_per_sample_ch, processed_genome, chromosome_list)
	variants_ch = CALL_VARIANTS.out.per_sample_vars

	//TODO: Add variant QC workflow

// 	========================================
//  TOOLS VERSION COLLECTION
//  ========================================
    
   channel.topic('versions')
       | unique()
       | map { proc, name, ver -> "${proc.tokenize(':').last()}: ${name}: ${ver}" }
       | collectFile(name: 'collated_versions.yml', newLine: true, storeDir: params.outdir)

}