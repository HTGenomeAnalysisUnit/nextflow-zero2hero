include { FASTP } from '../../modules/local/fastp'
include { RDEVAL } from '../../modules/local/rdeval'

workflow READS_QC {
	take:
		fastq_input // channel with tuples: [ sample_id, fastq_R1, fastq_R2 ]

	main:
		RDEVAL(fastq_input)
		FASTP(fastq_input)
	
	emit:
		qced_reads = FASTP.out.qced_reads
}