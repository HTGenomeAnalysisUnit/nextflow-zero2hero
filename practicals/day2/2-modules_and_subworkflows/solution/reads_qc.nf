include { FASTP } from './fastp'


workflow READS_QC {

    take:
        sample_reads // tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)

    main:

        FASTP(sample_reads)

    emit:
        qced_reads = FASTP.out.qced_reads

}

