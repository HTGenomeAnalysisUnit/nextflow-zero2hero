include { MOSDEPTH } from './mosdepth'
include { SAMTOOLS_STATS} from './samtools-stats'

workflow ALIGNMENT_QC {

    take:
        sorted_bam

    main:
        SAMTOOLS_STATS(sorted_bam)
        MOSDEPTH(sorted_bam)

}