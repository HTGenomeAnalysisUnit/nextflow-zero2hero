include { MULTIQC } from '../../modules/local/multiqc'

workflow REPORT {

    take:
        multiqc_files

    main:
        MULTIQC(multiqc_files)
}