include { MOSDEPTH } from '../../modules/local/mosdepth'
include { SAMTOOLS_STATS} from '../../modules/local/samtools-stats'

workflow ALIGNMENT_QC {

    take:
        sorted_bam

    main:
        SAMTOOLS_STATS(sorted_bam)
        MOSDEPTH(sorted_bam)

    emit:
        stats_file = SAMTOOLS_STATS.out.stats_file
        mosdepth_files = MOSDEPTH.out.mosdepth_files
}