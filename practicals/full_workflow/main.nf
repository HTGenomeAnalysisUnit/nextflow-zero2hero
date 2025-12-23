include { READS_QC } from './workflows/reads-qc'
include { ALIGN_AND_DEDUP } from './workflows/align'
include { ALIGNMENT_QC } from './workflows/align-qc'

workflow {
	input_fastq_ch = channel.fromPath(params.input_file)
		.splitCsv(header:true, sep:'\t')
		.map { row -> 
			[
				sample_id: row.sample_id, 
				fastq_R1: file(row.fastq_R1), 
				fastq_R2: file(row.fastq_R2)
			] 
		}

	READS_QC(input_fastq_ch)
	
	qc_reads_ch = READS_QC.out.qced_reads
	ALIGN_AND_DEDUP(qc_reads_ch)

	bam_per_sample_ch = ALIGN_AND_DEDUP.out.aligned_reads
	ALIGNMENT_QC(bam_per_sample_ch)

// 	========================================
//  TOOLS VERSION COLLECTION
//  ========================================
    
   channel.topic('versions')
       | unique()
       | map { proc, name, ver -> "${proc.tokenize(':').last()}: ${name}: ${ver}" }
       | collectFile(name: 'collated_versions.yml', newLine: true, storeDir: params.outdir)

}