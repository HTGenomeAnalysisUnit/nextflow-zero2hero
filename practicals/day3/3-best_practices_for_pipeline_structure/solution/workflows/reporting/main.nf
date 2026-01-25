include { MULTIQC } from '../../modules/local/multiqc'

workflow REPORT {

    take:
        multiqc_files
        multiqc_config
        ht_logo

    main:
        MULTIQC(
            multiqc_files, 
            multiqc_config,
            ht_logo)
}