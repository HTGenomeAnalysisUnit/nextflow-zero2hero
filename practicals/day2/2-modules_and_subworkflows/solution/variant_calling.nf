include { DEEPVARIANT } from './deepvariant'

workflow VARIANT_CALLING {

    take:
        sorted_bam
        genome_indexes

    main:
        deepvariant_input_ch = sorted_bam.combine(genome_indexes)
	    DEEPVARIANT(deepvariant_input_ch)

}