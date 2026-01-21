include { READS_QC } from './reads_qc'
include { ALIGNMENT } from './alignment'
include { ALIGNMENT_QC } from './alignment-qc'


workflow {


    // Prepare reference genome indices
	genome_indexes = channel.fromPath(params.reference_genome, checkIfExists: true)
    	.map { fasta_file -> 
        def genome_id = fasta_file.baseName
        def index_files = ['amb', 'ann', 'bwt', 'pac', 'sa', 'fai'].collect { ext ->
            file("${fasta_file}.${ext}")
        }
        tuple(genome_id, fasta_file, index_files)
    	}


    // Read samplesheet with the sample ids and fastq paths
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

    READS_QC(input_fastq_ch)

    ALIGNMENT(
        READS_QC.out.qced_reads,
        genome_indexes
    )

	ALIGNMENT_QC(
		ALIGNMENT.out.sorted_bam,
	)


}