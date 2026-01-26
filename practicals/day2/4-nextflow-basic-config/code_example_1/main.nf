include { PREPARE_GENOME  } from './workflows/prepare-genome'
include { FASTP           } from './modules/local/fastp'
include { ALIGNMENT       } from './workflows/align'

workflow {

	
	PREPARE_GENOME(params.reference_genome)
	processed_genome = PREPARE_GENOME.out.processed_genome
	
	/*def row_counter = 0
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

	FASTP(input_fastq_ch)
	
	qc_reads_ch = FASTP.out.qced_reads
	
	ALIGNMENT(qc_reads_ch, processed_genome)*/
	

}
