include { FASTP } from '../../modules/local/fastp'
include { RDEVAL } from '../../modules/local/rdeval'


workflow READS_QC {

    take:
        sample_reads

    main:

        FASTP(sample_reads)
        RDEVAL(sample_reads)

    emit:
        qced_reads = FASTP.out.qced_reads
        json_report = FASTP.out.fastp_json
}

