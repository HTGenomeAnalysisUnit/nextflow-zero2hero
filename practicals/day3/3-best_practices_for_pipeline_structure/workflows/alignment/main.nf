include { BWA_MEM } from '../../modules/local/bwa'
include { SAMTOOLS_SORT } from '../../modules/local/samtools-sort'
include { MOSDEPTH } from '../../modules/local/mosdepth'


workflow ALIGNMENT {

    take:
        qc_reads 
        genome_indexes

    main:
        bwa_input_ch = qc_reads.combine(genome_indexes)
        BWA_MEM(bwa_input_ch)
        bam_files_ch = BWA_MEM.out.bam_file

        SAMTOOLS_SORT(bam_files_ch)

    emit:
        sorted_bam = SAMTOOLS_SORT.out.sorted_bam
}